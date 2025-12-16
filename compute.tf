# ------------------------
# Bastion Host
# ------------------------
resource "aws_instance" "bastion_host" {
    for_each = aws_subnet.public
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    subnet_id = each.value.id
    key_name = aws_key_pair.ec2_keypair.key_name
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.public_ssh.id]

    tags = {
        Name = "bastion-host-${each.key}"
    }
}

# ------------------------
# Private EC2
# ------------------------
resource "aws_instance" "demo_ec2" {
    for_each = aws_subnet.private
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    subnet_id = each.value.id
    key_name = "iac-tutorial-keypair"
    associate_public_ip_address = false
    vpc_security_group_ids = [aws_security_group.private_ssh.id]

    tags = {
        Name = "demo-ec2-${each.key}"
    }
}