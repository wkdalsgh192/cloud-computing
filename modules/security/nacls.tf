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

# ------------------------
# Public NACL Rules
# A) Public -> Private App
# B) Private App -> Public
# ------------------------

# Outbound HTTPS Public -> Private App
resource "aws_network_acl_rule" "public_out_to_app_https" {
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

# Return traffic to public client: allow inbound ephemeral from app
resource "aws_network_acl_rule" "public_in_ephemeral_from_app" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210 + each.key
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}

# Inbound HTTPS from private app to public
resource "aws_network_acl_rule" "public_in_from_app_https" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.public.id
  rule_number    = 220 + each.key
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 443
  to_port        = 443
}

# Return traffic from public: allow outbound ephemeral to private app
resource "aws_network_acl_rule" "public_out_ephemeral_to_app" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.public.id
  rule_number    = 230 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}

# ------------------------
# Private NACL Rules
# A) Public -> Private App (Server in private app:443)
# B) Private App -> Public (client in private app)
# ------------------------

# Inbound app_port from Public -> Private App
resource "aws_network_acl_rule" "app_in_from_public_https" {
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
resource "aws_network_acl_rule" "app_out_ephemeral_to_public" {
  for_each       = local.public_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 110 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}

# Outbound HTTPS to public server
resource "aws_network_acl_rule" "app_out_to_public_https" {
  for_each       = local.public_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 120 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 443
  to_port        = 443
}

# Return traffic to Private App: allow inbound ephemeral from public
resource "aws_network_acl_rule" "app_in_ephemeral_from_public" {
  for_each       = local.public_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 130 + each.key
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
  rule_number    = 200 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = var.db_port
  to_port        = var.db_port
}

# Return traffic from DB port: allow inbound ephemeral to private app
resource "aws_network_acl_rule" "app_in_ephemeral_from_data" {
  for_each       = local.data_cidrs_by_idx
  network_acl_id = aws_network_acl.private_app.id
  rule_number    = 210 + each.key
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 1024
  to_port        = 65535
}

# ------------------------
# Private Data NACL Rules
# A) Private App -> Private Data (DB port)
# ------------------------

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

# Return traffic from DB server: allow outbound port to private app
resource "aws_network_acl_rule" "data_out_db_to_app" {
  for_each       = local.app_cidrs_by_idx
  network_acl_id = aws_network_acl.private_data.id
  rule_number    = 200 + each.key
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = var.db_port
  to_port        = var.db_port
}
