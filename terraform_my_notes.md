# What I have learned so far 
## Week 1
### Terraform 
Resources:
- https://devopsvn.tech/terraform-series/terraform
- Terraform Up & Running book

#### Core Concepts
- [x] What Infrastructure as Code is
<img width="1920" height="888" alt="image" src="https://github.com/user-attachments/assets/38de2b97-0539-4209-b9c1-4658d8ffb557" />

- [x] Terraform workflow: `init`, `fmt`, `plan`, `apply`, and `destroy`
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

#### Variables and Data Types
- [x] Declare variables via **variables.tf** file
- [x] Pass actual variable values through `terraform.tfvars` (don't push this file on Github)
- [x] Data types: `string`, `number`, and `bool`, `list`, `set`, `map`, `tuple`, and `object`
- [x] The difference between `list`, `tuple`, and `set`
- [x] Use variable validation to restrict valid input values
```terraform
provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {
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
- [x] Use `sensitive = true` for sensitive variables.


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

#### Data Sources
- [x] Understand that data sources are used to read existing information from AWS (does not create new resources)
- [x] Use data "aws_availability_zones" to get available Availability Zones.
- [x] Use data "aws_caller_identity" to get the AWS account ID.
- [x] Use data "aws_region" to get the current region.
- [x] Use data "aws_ami" to find AMIs to create EC2 instance.

#### Meta-arguments
- [x] `count` is used to create multiple resources by number.
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

#### Expressions and Functions
- [x] Cconditional expression: `condition ? true_value : false_value`.
- [x] `merge()` to combine tags.
- [ ] functions such as `length()`, `join()`, `split()`, and `contains()`.
- [ ] `jsonencode()` to generate JSON, especially for IAM policies.
- [ ] `file()` and `filebase64sha256()` for Lambda packages.
- [ ] `templatefile()` for more complex configuration templates.
- [x] `for` loop
```terraform
output "upper_names" {
  value = [for name in var.names : upper(name)]
}
```

#### Remote State
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
