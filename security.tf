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