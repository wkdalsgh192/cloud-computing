# ------------------------
# RDS Instance (PostgreSQL)
# ------------------------
resource "aws_db_instance" "demo_postgres" {
  identifier = "demo-postgres"

  engine         = "postgres"
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.demo_db_subnets.name

  publicly_accessible = false
  multi_az            = true           
  skip_final_snapshot = false            
  deletion_protection = false

  backup_retention_period = 7
  apply_immediately        = true

  tags = {
    Name = "demo-postgres"
  }
}