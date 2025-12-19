# ------------------------
# DB Subnet Group
# ------------------------
resource "aws_db_subnet_group" "demo_db_subnets" {
  name        = "demo-db-subnet-group"
  description = "RDS subnet group for private subnets"
  subnet_ids  = values(var.data_subnets_by_az)

  tags = {
    Name = "demo-db-subnet-group"
  }
}