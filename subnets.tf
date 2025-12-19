resource "aws_subnet" "public" {
  for_each = local.subnets.public

  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnets.private

  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "private-app-${each.key}"
    Tier = "private-app"
  }
}

resource "aws_subnet" "private_data" {
  for_each = local.subnets.private_data

  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "private-data-${each.key}"
    Tier = "private-data"
  }
}

# ------------------------
# DB Subnet Group
# ------------------------
resource "aws_db_subnet_group" "demo_db_subnets" {
  name        = "demo-db-subnet-group"
  description = "RDS subnet group for private subnets"
  subnet_ids  = values(aws_subnet.private_data)[*].id

  tags = {
    Name = "demo-db-subnet-group"
  }
}