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
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  subnets = {
    public = {
      for idx, az in local.azs :
      az => idx == 0 ? "10.0.0.0/25" : "10.0.0.128/25"
    }
    private = {
      for idx, az in local.azs :
      az => idx == 0 ? "10.0.1.0/24" : "10.0.2.0/24"
    }
  }
}