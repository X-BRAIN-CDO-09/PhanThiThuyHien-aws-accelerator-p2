Resources:
- https://devopsvn.tech/terraform-series/terraform
- Terraform Up & Running book

# Core Concepts
- [x] What Infrastructure as Code is
<img width="1920" height="888" alt="image" src="https://github.com/user-attachments/assets/38de2b97-0539-4209-b9c1-4658d8ffb557" />

- [x] Terraform workflow: `init`, `fmt`, `plan`, `apply`, and `destroy`
- When there are many resources, pure `plan` command can take long time to complete, we can accelerate the process by running `terraform plan -parallelism=2`
- `terraform plan -out plan.out` allows us to store plan result in plan.out file. If you prefer JSON format, use this instead `terraform show -json plan.out > plan.json`

- [x] The meaning of Terraform plan symbols: `+` create, `~` update in-place, `-` destroy, and `-/+` destroy & recreate
- [x] Define a `provider`, `resource`, `data source`
```terraform
variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
  default     = "Xbrain-w5"
}
```

```terraform
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
```

Use `data` block to make API calls to AWS via Provider to get resource information, there is no resource creations happening here
```terraform
data "aws_ami" "ubuntu" { # amazon machine image
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical Ubuntu AWS account id
}

resource "aws_instance" "hello" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld"
  }
}
```

- [x] Reference resource attributes using `<resource_type>.<resource_name>.<attribute>`
```terraform
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-1234567890abcdef0"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server"
  }
}
```

## Functional Programming
### Variables & Data types
- [x] Declare variables via **variables.tf**
- [x] Pass actual variable values through `terraform.tfvars` (don't push this file onto Github)
- [x] Data types: `string`, `number`, `bool`, `list`, `set`, `map`, `tuple`, and `object`
```terraform 
variable "map_example" {
  description = "An example of a map in Terraform"
  type        = map(string)

  default = {
    key1 = "value1"
    key2 = "value2"
    key3 = "value3"
  }
}
```

```terraform
variable "object_example" {
  description = "An example of a structural type in Terraform"

  type = object({
    name    = string
    age     = number
    tags    = list(string)
    enabled = bool
  })

  default = {
    name    = "value1"
    age     = 42
    tags    = ["a", "b", "c"]
    enabled = true
  }
}
```
- [x] The difference between `list`, `tuple`, and `set`
- [x] Use variable validation to restrict valid input values
```terraform
variable "instance_type" {
  type = string
  description = "Instance type of the EC2"

  validation {
    condition = contains(["t2.micro", "t3.small"], var.instance_type)
    error_message = "Value not allow."
  }
}
```
- [x] Use `sensitive = true` for sensitive variables (become masked)

### Meta-arguments
- [x] `count` is used to create multiple resources by number.
```terraform
variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
  default     = ["alice", "bob", "charlie"]
}

module "users" {
  source    = "../../../modules/landing-zone/iam-user"
  count     = length(var.user_names)
  user_name = var.user_names[count.index]
}

```
- [x] `for_each` is used to create multiple resources from a map or set.
```terraform
resource "aws_iam_user" "users" {
  for_each = toset(["alice", "bob", "charlie"])
  name     = each.key # Evaluates to "alice", "bob", then "charlie"
}
```
- [x] Understand when to use `count` and when to use `for_each`.
- [x] Know how to use `depends_on` to control resource creation order.
- [ ] Understand the lifecycle block.
- [ ] Know how to use `prevent_destroy` to protect important resources.
- [ ] Know how to use `ignore_changes` when some configuration is managed outside Terraform.
- [ ] Know how to use `create_before_destroy` to reduce downtime.


#### Modules
- [x] Understand what Terraform modules are and why they are useful.
- [x] Understand the difference between the root module and child modules.
- [x] Know the standard module structure: `main.tf`, `variables.tf`, and `outputs.tf`.
- [x] Know how to pass input variables into a module.
- [x] Know how to access module outputs using `module.<name>.<output>`.
- [x] Know how to pass output from one module as input to another module.
- [ ] Know how to organize Terraform projects using `modules/` and `environments/`.
- [ ] Know how to use local modules and remote modules from Git.
- [ ] Understand module versioning using Git tags.

#### Locals and Outputs
- [x] Understand how `locals` are used to define reusable internal values.
- [x] How to output values such as: VPC ID, subnet ID, Lambda ARN, and API Gateway endpoint after `terraform apply`

#### Expressions and Functions
- [x] Cconditional expression: `condition ? true_value : false_value`.
- [x] `merge()` to combine tags.
- [ ] functions such as `length()`, `join()`, `split()`, and `contains()`.
- [ ] `jsonencode()` to generate JSON, especially for IAM policies.
- [ ] `file()` and `filebase64sha256()` for Lambda packages.
- [ ] `templatefile()` for more complex configuration templates.
- [x] `for` loop
<img width="637" height="114" alt="image" src="https://github.com/user-attachments/assets/04a30db4-a20e-4a32-a0d3-fa30b90d2844" />


# Manage Resource Life Cycle 
docs: https://developer.hashicorp.com/terraform/tutorials/state/resource-lifecycle 

<img width="400" height="390" alt="image" src="https://github.com/user-attachments/assets/60c8edf5-b8aa-49f2-8d05-f1f60ac11fe0" />

In Terraform, resource has 2 properties: Force New and Normal Update
- Force New: Resource is deleted and created new one
- Normal Update: Resource is updated normally
> **S3 bucket name is a Force New property**, so if we change bucket name, Terraform will delete the current bucket and create a new one with that given name. 

### Delete resources 
After running `destroy` command, Terraform workspace will look like:
```
.
├── main.tf
├── terraform.tfstate
└── terraform.tfstate.backup
```
- `terraform.tfstate.backup` is used to view the previous state of resources
- Deleting all configurations in Terraform folder is equivalent to running `terraform destroy` command

### Resource Drift 
It happens when resource configurations are changed outside of Terraform (maybe someone makes changes in AWS Console)

For example, here is my S3 bucket: 
``` terraform
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "terraform-bucket" {
  bucket = "terraform-series-bucket-update"

  tags = {
    Name        = "Terraform Series"
  }
}
```
Then, I change Name to "Terraform Drift Series" (**Tags**). 
When running `terraform plan`, Terraform will detect the change, and after `terraform apply` is hit, the Name will be changed to the original one - "Terraform Series"

## Remote State
- [x] Understand the difference between local state and remote state.
- [x] Know how to use S3 to store remote state.
- [x] Know how to use DynamoDB for state locking.
- [x] Understand that S3 stores the `terraform.tfstate` file.
- [x] Understand that DynamoDB prevents multiple people from running `terraform apply` at the same time.
- [ ] Know how to configure an S3 backend.
- [x] Know how to enable versioning for the S3 state bucket.
- [ ] Know how to restore an old state file from S3 when needed.
- [ ] Know how to handle state drift using `terraform plan`, `terraform import`, `terraform state rm`, and `terraform apply -refresh-only`.

#### State Management
- [ ] Know how to list resources in state using `terraform state list`.
- [ ] Know how to inspect a resource in state using `terraform state show`.
- [ ] Know how to rename or move a resource address using `terraform state mv`.
- [ ] Know how to remove a resource from state using `terraform state rm`.
- [ ] Know how to import an existing AWS resource into Terraform state.
- [ ] Know how to use the `moved` block when refactoring resources or modules.
- [ ] Understand what drift means when AWS resources are changed outside Terraform.
- [ ] Know how to use `terraform plan` to detect drift.
