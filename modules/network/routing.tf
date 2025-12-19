# ------------------------
# IGW
# ------------------------
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id
}

# ------------------------
# NAT Gateway
# ------------------------
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = {
    Name = "nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "demo_nat" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "demo-nat-${each.key}"
  }
  depends_on = [aws_internet_gateway.demo_igw]
}

# ------------------------
# Routing Tables
# ------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }
}

resource "aws_route_table" "private_rt" {
  for_each = aws_nat_gateway.demo_nat
  vpc_id   = aws_vpc.demo_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
}

resource "aws_route_table" "private_data_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "rt-private-data"
    Tier = "data"
  }
}


# ------------------------
# Route Associations
# ------------------------
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}

resource "aws_route_table_association" "private_data_assoc" {
  for_each = aws_subnet.private_data

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_data_rt.id
}
