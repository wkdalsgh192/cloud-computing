# ------------------------
# Security Groups
# ------------------------
resource "aws_security_group" "public_alb" {
  name        = "public_sg_https"
  description = "public ALB Security Group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "public_ssh" {
  name        = "public_sg_ssh"
  description = "public bastion host Security Group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "private" {
  name        = "private_sg_https"
  description = "private app tier Security Group"
  vpc_id      = var.vpc_id

}

resource "aws_security_group" "private_data" {
  name        = "private_data_sg"
  description = "Allow DB access from app tier only"
  vpc_id      = var.vpc_id
}

# ------------------------
# Security Group Rules
# ------------------------

# ------------------------
# ALB rules
# ------------------------

resource "aws_security_group_rule" "alb_in_http" {
  type              = "ingress"
  security_group_id = aws_security_group.public_alb.id
  description       = "HTTP for redirect"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_in_https" {
  type              = "ingress"
  security_group_id = aws_security_group.public_alb.id
  description       = "HTTPS"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

# ALB egress to App targets
resource "aws_security_group_rule" "alb_out_to_app_443" {
  type                     = "egress"
  security_group_id        = aws_security_group.public_alb.id
  description              = "Forward to app targets"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.private.id
}

# ------------------------
# Bastion rules (SSH)
# ------------------------

# SSH access must be restricted to approved admin IP addresses
resource "aws_security_group_rule" "bastion_in_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.public_ssh.id
  description       = "SSH from approved admin IPs"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"] # NOT SECURE: for demo purposes only
}

# Allow bastion outbound anywhere (common)
resource "aws_security_group_rule" "bastion_out_all" {
  type              = "egress"
  security_group_id = aws_security_group.public_ssh.id
  description       = "Outbound"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

# ------------------------
# App tier rules
# ------------------------
resource "aws_security_group_rule" "app_in_from_alb_443" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private.id
  description              = "HTTPS from ALB"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "app_in_ssh_from_bastion" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private.id
  description              = "SSH from bastion only"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = aws_security_group.public_ssh.id
}

resource "aws_security_group_rule" "app_out_to_db" {
  type                     = "egress"
  security_group_id        = aws_security_group.private.id
  description              = "App to data tier"
  protocol                 = "tcp"
  from_port                = var.db_port
  to_port                  = var.db_port
  source_security_group_id = aws_security_group.private_data.id
}

# App outbound HTTPS (updates, external APIs) for strict least-privilege
resource "aws_security_group_rule" "app_out_https" {
  type              = "egress"
  security_group_id = aws_security_group.private.id
  description       = "Outbound HTTPS"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

# ------------------------
# Data tier rules
# ------------------------

resource "aws_security_group_rule" "data_in_from_app" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_data.id
  description              = "DB port from app"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private.id
}