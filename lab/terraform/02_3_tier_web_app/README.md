## Requirement

![alt text](assets/requirement.png)

# How to run

- Run: \
  `terraform plan` \
  `terraform apply -var-file=terraform.tfvars -input=false`
  ![alt text](assets/apply.png)
- Then get the website address: `terraform output public_ip`
  ![alt text](assets/output.png)
- Open: **http://<public_ip>**
  ![alt text](assets/image-4.png)
  ![alt text](assets/image-6.png)
  ![alt text](assets/image-5.png)
- Destroy all managed resources: \
  `terraform destroy -var-file=terraform.tfvars -auto-approve`
