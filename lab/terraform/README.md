## Requirement

![alt text](02_3_tier_web_app/assets/requirement.png)

# How to run

- Run: \
  `terraform plan` \
  `terraform apply -var-file=terraform.tfvars -input=false`
  ![alt text](02_3_tier_web_app/assets/apply.png)
- Then get the website address: `terraform output public_ip`
  ![alt text](02_3_tier_web_app/assets/output.png)
- Open: **http://<public_ip>**
  ![alt text](02_3_tier_web_app/assets/image-4.png)
  ![alt text](02_3_tier_web_app/assets/image-6.png)
  ![alt text](02_3_tier_web_app/assets/image-5.png)
- Destroy all managed resources: \
  `terraform destroy -var-file=terraform.tfvars -auto-approve`
