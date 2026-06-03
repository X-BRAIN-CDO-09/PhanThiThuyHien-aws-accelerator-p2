# What I have learned so far 
## Week 1
### Terraform 
#### Core Concepts
- [x] What Infrastructure as Code is.
- [x] The Terraform workflow: `init`, `fmt`, `plan`, `apply`, and `destroy`.
- [x] The meaning of Terraform plan symbols: `+`, `~`, `-`, and `-/+`.
- [x] Define a `provider`, `resource`, `data source`.
- [x] Reference resource attributes using `<resource_type>.<resource_name>.<attribute>`.

#### Variables and Data Types
- [x] Declare variables.
- [x] Pass variable values through `terraform.tfvars`.
- [x] Data types: `string`, `number`, and `bool`, `list`, `set`, `map`, `tuple`, and `object`.
- [x] The difference between `list`, `tuple`, and `set`.
- [x] Use variable validation to restrict valid input values.
- [x] Use `sensitive = true` for sensitive variables.

#### Locals and Outputs
- [x] Understand how `locals` are used to define reusable internal values.
- [x] Know how to output values such as: VPC ID, subnet ID, Lambda ARN, and API Gateway endpoint after `terraform apply`

#### Data Sources
- [x] Understand that data sources are used to read existing information from AWS (does not create new resources)
- [x] Use data "aws_availability_zones" to get available Availability Zones.
- [x] Use data "aws_caller_identity" to get the AWS account ID.
- [x] Use data "aws_region" to get the current region.
- [x] Use data "aws_ami" to find AMIs to create EC2 instance.

#### Meta-arguments
- [x] `count` is used to create multiple resources by number.
- [x] `for_each` is used to create multiple resources from a map or set.
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
