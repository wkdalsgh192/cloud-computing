# ------------------------
# Security Group for RDS (Allow inbound ONLY from app SG)
# ------------------------
resource "aws_security_group" "public_alb" {
  name        = "public_sg_https"
  description = "Allow HTTPS"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP for redirect"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_ssh" {
  name        = "public_sg_ssh"
  description = "Allow SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  name        = "private_sg_https"
  description = "Allow HTTPS for private app tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ssh.id]
  }
}

resource "aws_security_group" "private_data" {
  name        = "private_data_sg"
  description = "Allow DB access from app tier only"
  vpc_id      = var.vpc_id
}

# ------------------------
# Security Group Rules
# ------------------------

resource "aws_security_group_rule" "alb_to_app_egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.public_alb.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "app_to_data_egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.private.id
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private_data.id
}

resource "aws_security_group_rule" "data_from_app_ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.private_data.id
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private.id
}