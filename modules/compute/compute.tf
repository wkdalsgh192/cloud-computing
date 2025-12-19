# ------------------------
# Bastion Host
# ------------------------
resource "aws_instance" "bastion_host" {
  for_each                    = var.public_subnets_by_az
  subnet_id                   = each.value
  availability_zone           = each.key
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_sg_id]

  tags = {
    Name = "bastion-host-${each.key}"
  }
}

# ------------------------
# Private EC2
# ------------------------
resource "aws_instance" "demo_ec2" {
  for_each                    = var.private_subnets_by_az
  subnet_id                   = each.value
  availability_zone           = each.key
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.app_sg_id]

  tags = {
    Name = "demo-ec2-${each.key}"
  }
}