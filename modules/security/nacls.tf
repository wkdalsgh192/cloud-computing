# ------------------------
# NACL
# ------------------------
resource "aws_network_acl" "public" {
  vpc_id = var.vpc_id
  tags = {
    Name = "demo-public-nacl"
    Tier = "public"
  }
}

resource "aws_network_acl" "private_app" {
  vpc_id = var.vpc_id
  tags = {
    Name = "demo-private-app-nacl"
    Tier = "private-app"
  }
}

resource "aws_network_acl" "private_data" {
  vpc_id = var.vpc_id
  tags = {
    Name = "demo-private-data-nacl"
    Tier = "private-data"
  }
}

# ------------------------
# NACL Association
# ------------------------
resource "aws_network_acl_association" "public" {
  for_each       = var.public_subnets_by_az
  network_acl_id = aws_network_acl.public.id
  subnet_id      = each.value
}

resource "aws_network_acl_association" "private_app" {
  for_each       = var.private_subnets_by_az
  network_acl_id = aws_network_acl.private_app.id
  subnet_id      = each.value
}

resource "aws_network_acl_association" "private_data" {
  for_each       = var.data_subnets_by_az
  network_acl_id = aws_network_acl.private_data.id
  subnet_id      = each.value
}

# ------------------------
# NACL Rules
# ------------------------

# Outbound app_port Public -> Private App
resource "aws_network_acl_rule" "public_out_to_app_port" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 443
  to_port        = 443
}

# Outbound ephemeral Public -> Private App (return traffic)
resource "aws_network_acl_rule" "public_out_ephemeral_to_app" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.public.id
  rule_number    = 300 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}

# Inbound app_port from Public -> Private App
resource "aws_network_acl_rule" "app_in_from_public_port" {
  for_each       = local.public_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 100 + each.key
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 443
  to_port        = 443
}

# Inbound ephemeral from Public -> Private App (return traffic)
resource "aws_network_acl_rule" "app_in_ephemeral_from_public" {
  for_each       = local.public_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 200 + each.key
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}

# Outbound DB port Private App -> Private Data
resource "aws_network_acl_rule" "app_out_to_data_db_port" {
  for_each       = local.data_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 300 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = var.db_port
  to_port        = var.db_port
}

# Outbound ephemeral Private App -> Private Data (return traffic)
resource "aws_network_acl_rule" "app_out_ephemeral_to_data" {
  for_each       = local.data_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 400 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}

# Inbound DB port from Private App -> Private Data
resource "aws_network_acl_rule" "data_in_db_from_app" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.private_data.id
  rule_number    = 100 + each.key
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = var.db_port
  to_port        = var.db_port
}

# Outbound ephemeral Private Data -> Private App (return traffic)
resource "aws_network_acl_rule" "data_out_ephemeral_to_app" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.private_data.id
  rule_number    = 200 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}
