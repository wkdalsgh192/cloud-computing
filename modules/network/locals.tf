locals {
  public_subnets = {
    for idx, az in var.azs :
    az => var.public_subnet_cidrs[idx]
  }

  app_subnets = {
    for idx, az in var.azs :
    az => var.app_subnet_cidrs[idx]
  }

  data_subnets = {
    for idx, az in var.azs :
    az => var.data_subnet_cidrs[idx]
  }

  public_cidrs_by_idx = {
    for idx, cidr in values(local.public_subnets) :
    idx => cidr
  }

  app_cidrs_by_idx = {
    for idx, cidr in values(local.app_subnets) :
    idx => cidr
  }

  data_cidrs_by_idx = {
    for idx, cidr in values(local.data_subnets) :
    idx => cidr
  }
}
