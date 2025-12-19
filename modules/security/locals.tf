locals {
  public_cidrs_by_idx = {
    for idx, cidr in var.public_subnet_cidrs :
    idx => cidr
  }

  app_cidrs_by_idx = {
    for idx, cidr in var.app_subnet_cidrs :
    idx => cidr
  }

  data_cidrs_by_idx = {
    for idx, cidr in var.data_subnet_cidrs :
    idx => cidr
  }
}