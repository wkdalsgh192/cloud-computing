variable "domain_name" {
  type        = string
  description = "Domain name for the application"
  default     = "minho-jang.com"
}

variable "region" {
  default = "us-west-2"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
  default     = "appdb"
}

variable "db_username" {
  type        = string
  description = "Master username"
  default     = "appadmin"
}

variable "db_port" {
  type        = number
  description = "Postgres port"
  default     = 5432
}

variable "db_password" {
  type        = string
  description = "Master password for RDS"
  sensitive   = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "az_count" {
  type    = number
  default = 1
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  # ----------------------------
  # Availability Zones (1~5)
  # ----------------------------
  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    min(var.az_count, length(data.aws_availability_zones.available.names))
  )

  # ----------------------------
  # CIDR ranges per tier
  # Index corresponds to AZ index
  # ----------------------------
  public_subnet_cidr_range = [
    "10.0.0.0/25",
    "10.0.1.0/25",
    "10.0.2.0/25",
    "10.0.3.0/25",
    "10.0.4.0/25",
  ]

  private_app_subnet_cidr_range = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
    "10.0.14.0/24",
  ]

  private_data_subnet_cidr_range = [
    "10.0.20.0/26",
    "10.0.21.0/26",
    "10.0.22.0/26",
    "10.0.23.0/26",
    "10.0.24.0/26",
  ]

  # ----------------------------
  # Final subnet maps (AZ → CIDR)
  # ----------------------------
  subnets = {
    public = {
      for idx, az in local.azs :
      az => local.public_subnet_cidr_range[idx]
    }

    private = {
      for idx, az in local.azs :
      az => local.private_app_subnet_cidr_range[idx]
    }

    private_data = {
      for idx, az in local.azs :
      az => local.private_data_subnet_cidr_range[idx]
    }
  }

  public_cidrs       = values(local.subnets.public)
  private_app_cidrs  = values(local.subnets.private)
  private_data_cidrs = values(local.subnets.private_data)

  # index-keyed maps so rule_number can be deterministic
  public_cidrs_by_idx = { for idx, cidr in local.public_cidrs : idx => cidr }
  app_cidrs_by_idx    = { for idx, cidr in local.private_app_cidrs : idx => cidr }
  data_cidrs_by_idx   = { for idx, cidr in local.private_data_cidrs : idx => cidr }

  # subnet-id maps for NACL associations
  # public_subnet_ids_by_idx = { for idx, id in local.public_subnet_ids : idx => id }
  # app_subnet_ids_by_idx    = { for idx, id in local.private_app_subnet_ids : idx => id }
  # data_subnet_ids_by_idx   = { for idx, id in local.private_data_subnet_ids : idx => id }
}