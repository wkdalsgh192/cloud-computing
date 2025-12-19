resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/20"

  tags = {
    Name = "demo_vpc"
  }
}