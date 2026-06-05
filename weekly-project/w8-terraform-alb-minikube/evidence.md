## Proposed Architecture
![alt text](./assets/architecture.png)

## Sequence Diagram
![alt text](./assets/sequential_diagram.png)

## Result
![alt text](./assets/terraform_done.png)
![alt text](./assets/web.png)

## EC2 User Data Script
`user_data.sh` plays an important role in the project, helping us automate bootstraping tasks like software installation, updates, and configuration. So what does the file handle in detail?
1. Update system packages 
2. Download frontend file from S3 and save it in EC2 instance
   ```bash
   aws s3 cp "s3://$${FRONTEND_BUCKET}/$${FRONTEND_KEY}" /tmp/index.html
   ```
3. Install Docker
4. Create minikube user, install kubectl and minikube
5. Run minikube through **Docker Driver** 
   ```bash
   minikube start --driver=docker \
      --container-runtime=docker 
      --cpus=2 
      --memory=1800mb 
      --ports=$${NODE_PORT}:$${NODE_PORT}
   ```
6. Create frontend **ConfigMap** which is an API object used to store non-confidential configuration data in key-value pairs in Kubernetes
   ```bash
   kubectl create configmap frontend-html \
     --from-file=index.html=/tmp/index.html \
     -n app \
     --dry-run=client \
     -o yaml | kubectl apply -f -
   ```

   The ConfigMap will look like this:
   ```yaml 
   apiVersion: v1
   kind: ConfigMap
   metadata:
      name: frontend-html
   data:
      index.html: |
         <!DOCTYPE html>
         <html>
      ...
   ``` 
7. Create **Kubernetes Deployment to run frontend app** using Nginx container
   - Run Nginx container
   - Mount index.html from ConfigMap
   - Expost container on port 80
   - Create Pod instances based on APP_REPLICAS
8. Create **Kubernetes Service** having the important configuration "**spec type is NodePort**". This means Kubernetes will open a fixed port on Kubernetes Node to allow outbound traffics  


## Check Pods

1. `aws ssm start-session --target i-03ef9f62c71eeb3e4`

2. View Pod in Kubernetes: `sudo -u minikube -H kubectl get pods -n app -o wide`
   ![alt text](./assets/view_pod.png)

