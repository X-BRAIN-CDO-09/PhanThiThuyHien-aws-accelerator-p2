# Amazon Macie sensitive-data detection lab

This Terraform project deploys the complete flow shown in the lab diagram:

1. A private, versioned, SSE-S3-encrypted bucket is created.
2. Synthetic sample records are uploaded to the bucket.
3. Amazon Macie is enabled and a one-time classification job scans the bucket.
4. An EventBridge rule matches `Macie Finding` events.
5. EventBridge publishes each finding to an SNS topic.
6. SNS sends the notification to a confirmed email subscriber.

The sample records are entirely synthetic. Do not put real sensitive data in this repository.

## Prerequisites

- Terraform 1.5 or newer
- AWS CLI credentials for the target account
- An AWS Region where Amazon Macie is available (the default is Singapore, `ap-southeast-1`)
- Permissions to manage S3, Macie, EventBridge, and SNS, plus `iam:CreateServiceLinkedRole` when Macie is enabled for the first time

Macie classification is a paid AWS service. The sample data is tiny, but review current Macie pricing before applying this configuration.

## Deploy

From PowerShell in this directory:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars

aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan -out macie.tfplan
terraform apply macie.tfplan
```

While `terraform apply` is running, open the message from **AWS Notifications** and click **Confirm subscription**. Terraform cannot automate this security confirmation. The configuration waits two minutes for Macie inventory propagation before starting the scan, which also gives you time to confirm the subscription.

The Macie job runs asynchronously after it is created. Findings can take several minutes to appear. Use the `macie_console_url` output to open the findings page:

```powershell
terraform output macie_console_url
```

If the subscription was not confirmed before the first finding was published, confirm it and create a replacement job:

```powershell
terraform apply -replace=aws_macie2_classification_job.sensitive_data
```

## Existing Macie account

Macie can only be enabled once per account and Region. If it is already enabled but is not in this Terraform state, import it before the main apply:

```powershell
$accountId = aws sts get-caller-identity --query Account --output text
terraform import aws_macie2_account.this $accountId
```

If AWS says the new bucket is not yet available in the Macie inventory, increase `macie_inventory_wait` in `terraform.tfvars` (for example, to `5m`) and apply again.

## Clean up

```powershell
terraform destroy
```

The lab defaults `force_destroy_bucket` to `true`, so cleanup removes all sample object versions. Destroying this stack also disables the regional Macie account managed by this state. If Macie is shared with other workloads, remove the Macie account resource from this state before cleanup rather than disabling the service.
