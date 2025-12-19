output "bastion_host_ips" {
  description = "Public IPs of bastion hosts"
  value = {
    for k, v in aws_instance.bastion_host :
    k => v.public_ip
  }
}

output "private_ec2_ip" {
  description = "Private IPs of private ec2 instances"
  value = {
    for k, v in aws_instance.demo_ec2 :
    k => v.private_ip
  }
}