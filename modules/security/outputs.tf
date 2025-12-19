output "public_ssh_sg_id" {
  value = aws_security_group.public_ssh.id
}

output "private_app_sg_id" {
  value = aws_security_group.private.id
}

output "data_sg_id" {
  value = aws_security_group.private_data.id
}