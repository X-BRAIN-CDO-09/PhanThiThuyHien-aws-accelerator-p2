output "instance_id" {
  value = aws_instance.minikube.id
}

output "private_ip" {
  value = aws_instance.minikube.private_ip
}

output "availability_zone" {
  value = aws_instance.minikube.availability_zone
}