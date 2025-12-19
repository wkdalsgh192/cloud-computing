data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    min(var.az_count, length(data.aws_availability_zones.available.names))
  )

  # CIDR policy (explicit & reviewable)
  public_subnet_cidrs = [
    "10.0.0.0/25",
    "10.0.1.0/25",
    "10.0.2.0/25",
  ]

  app_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
  ]

  data_subnet_cidrs = [
    "10.0.20.0/24",
    "10.0.21.0/24",
    "10.0.22.0/24",
  ]
}
