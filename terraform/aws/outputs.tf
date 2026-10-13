output "public_ip" {
  value = aws_eip.node.public_ip
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ssh_command" {
  value = "ssh ubuntu@${aws_eip.node.public_ip}"
}

output "app_url" {
  value = "http://${aws_eip.node.public_ip}:30080"
}

output "grafana_url" {
  value = "http://${aws_eip.node.public_ip}:30030"
}

output "prometheus_url" {
  value = "http://${aws_eip.node.public_ip}:30090"
}
