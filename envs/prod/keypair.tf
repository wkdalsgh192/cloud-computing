# Note: Only for demo project. Use SSM Session Manager instead of SSH in real production env.
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "demo-keypair"
  public_key = tls_private_key.ec2_key.public_key_openssh
}