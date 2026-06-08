resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.ec2_sg_id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user_data.sh", {
    db_host     = var.db_host
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  })

  tags = {
    Name = "${var.project_name}-web-server"
  }
}