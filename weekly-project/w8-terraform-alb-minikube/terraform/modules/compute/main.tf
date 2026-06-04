locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# AMI for ec2
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    ]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Minikube
data "cloudinit_config" "minikube" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "user_data.sh"
    content_type = "text/x-shellscript"

    content = templatefile("${path.root}/scripts/user_data.sh", {
      node_port       = var.node_port
      app_image       = var.app_image
      app_replicas    = var.app_replicas
      frontend_bucket = var.frontend_bucket
      frontend_key    = var.frontend_key
    })
  }
}

resource "aws_instance" "minikube" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.ec2_security_group_id]
  iam_instance_profile   = var.instance_profile_name

  user_data                   = data.cloudinit_config.minikube.rendered
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(local.common_tags, {
    Name = "minikube-node"
  })
}