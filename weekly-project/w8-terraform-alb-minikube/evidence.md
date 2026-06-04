Terraform output values:
![alt text](./assets/terraform_done.png)

![alt text](./assets/web.png)

Ensure the simple application is running in Kuberneters Pod, not in EC2
sudo -u minikube -H kubectl get pods -n app -o wide
![alt text](image.png)

ps aux | grep nginx
![alt text](image-1.png)

Check user **minikube** in EC2
1. aws ssm start-session --target i-052ada0ef36eca860
2. id minikube
![alt text](image-2.png)
3. View Pod in Kubernetes: sudo -u minikube -H kubectl get pods -n app -o wide
![alt text](image-3.png)
4. Pick 1 Pod

POD_NAME=$(sudo -u minikube -H kubectl get pod -n app -l app=simple-app -o jsonpath='{.items[0].metadata.name}') \
echo $POD_NAME$

5. Exec this Pod

sudo -u minikube -H kubectl exec -n app -it "$POD_NAME" -- sh
![alt text](image-4.png)
![alt text](image-5.png)