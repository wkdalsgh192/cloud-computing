# ------------------------
# NACL
# ------------------------
resource "aws_network_acl" "public" {
    vpc_id = aws_vpc.demo_vpc.id

    tags = {
        Name = "demo-public-nacl"
    }
}

resource "aws_network_acl_rule" "inbound_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number = 100
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

resource "aws_network_acl_rule" "outbound_https" {
    for_each = local.subnets.private
    network_acl_id = aws_network_acl.public.id
    rule_number = 100 + index(local.subnets.private, each.value)
    egress = true
    protocol = "tcp"
    rule_action = "allow"
    cidr_block = each.value
    from_port = 443
    to_port = 443
}

resource "aws_network_acl" "private" {
    vpc_id = aws_vpc.demo_vpc.id

    tags = {
        Name = "demo-private-nacl"
    }
}

resource "aws_network_acl_rule" "private_inbound_https" {
  network_acl_id = aws_network_acl.private.id
  rule_number = 100
  egress = false
  protocol = "tcp"
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

resource "aws_network_acl_rule" "private_outbound_https" {
    for_each = local.subnets.private
    network_acl_id = aws_network_acl.private.id
    rule_number = 100 + index(local.subnets.private, each.value)
    egress = true
    protocol = "tcp"
    rule_action = "allow"
    cidr_block = each.value
    from_port = 443
    to_port = 443
}


# ------------------------
# Security Group for RDS (Allow inbound ONLY from app SG)
# ------------------------
resource "aws_security_group" "rds_sg" {
  name        = "demo-rds-sg"
  description = "Allow Postgres from app instances only"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    description     = "Postgres from app SG"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.private_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-rds-sg"
  }
}