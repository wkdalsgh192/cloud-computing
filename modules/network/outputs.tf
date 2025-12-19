output "vpc_id" {
  value = aws_vpc.demo_vpc.id
}

output "public_subnets_by_az" {
  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.id
  }
}

output "private_subnets_by_az" {
  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.id
  }
}

output "data_subnets_by_az" {
  value = {
    for az, subnet in aws_subnet.private_data :
    az => subnet.id
  }
}