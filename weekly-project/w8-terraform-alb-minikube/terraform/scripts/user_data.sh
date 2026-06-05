#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/minikube-bootstrap.log | logger -t minikube-bootstrap -s 2>/dev/console) 2>&1

NODE_PORT="${node_port}"
APP_IMAGE="${app_image}"
APP_REPLICAS="${app_replicas}"
FRONTEND_BUCKET="${frontend_bucket}"
FRONTEND_KEY="${frontend_key}"

export DEBIAN_FRONTEND=noninteractive

echo "========== Update system =========="
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common awscli

echo "========== Download frontend file from S3 =========="
aws s3 cp "s3://$${FRONTEND_BUCKET}/$${FRONTEND_KEY}" /tmp/index.html
chmod 644 /tmp/index.html

echo "========== Install Docker =========="
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "========== Create minikube user =========="
id -u minikube >/dev/null 2>&1 || useradd -m -s /bin/bash minikube
usermod -aG docker minikube

echo "========== Install kubectl =========="
curl -LO "https://dl.k8s.io/release/v1.30.5/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

echo "========== Install minikube =========="
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64

echo "========== Start minikube =========="
sudo -u minikube -H bash <<EOF
set -euxo pipefail

minikube delete || true

minikube start --driver=docker --container-runtime=docker --cpus=2 --memory=1800mb --ports=$${NODE_PORT}:$${NODE_PORT}

kubectl config use-context minikube

kubectl create namespace app --dry-run=client -o yaml | kubectl apply -f -

echo "========== Create frontend ConfigMap =========="
kubectl create configmap frontend-html \
  --from-file=index.html=/tmp/index.html \
  -n app \
  --dry-run=client \
  -o yaml | kubectl apply -f -

echo "========== Deploy frontend app =========="
cat <<YAML | kubectl apply -n app -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-app
  labels:
    app: simple-app
spec:
  replicas: $${APP_REPLICAS}
  selector:
    matchLabels:
      app: simple-app
  template:
    metadata:
      labels:
        app: simple-app
    spec:
      containers:
        - name: simple-app
          image: $${APP_IMAGE}
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
          volumeMounts:
            - name: frontend-html
              mountPath: /usr/share/nginx/html/index.html
              subPath: index.html
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 20
            periodSeconds: 10
          resources:
            requests:
              cpu: "25m"
              memory: "32Mi"
            limits:
              cpu: "100m"
              memory: "128Mi"
      volumes:
        - name: frontend-html
          configMap:
            name: frontend-html
YAML

echo "========== Create Kubernetes Service =========="
cat <<YAML | kubectl apply -n app -f -
apiVersion: v1
kind: Service
metadata:
  name: simple-app-service
  labels:
    app: simple-app
spec:
  type: NodePort
  selector:
    app: simple-app
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
      nodePort: $${NODE_PORT}
YAML

kubectl rollout status deployment/simple-app -n app --timeout=300s
kubectl get nodes -o wide
kubectl get pods -n app -o wide
kubectl get svc -n app -o wide
kubectl get configmap frontend-html -n app
EOF

echo "========== Verify NodePort from EC2 host =========="
for i in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:$${NODE_PORT}" >/dev/null; then
    echo "Application is reachable on EC2 host port $${NODE_PORT}"
    exit 0
  fi

  echo "Waiting for app on EC2 host port $${NODE_PORT}..."
  sleep 10
done

echo "Application did not become reachable on EC2 host port $${NODE_PORT}"
docker ps
sudo -u minikube -H kubectl get pods -n app -o wide || true
sudo -u minikube -H kubectl get svc -n app -o wide || true
exit 1