variable "environment" {
  type = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "domain_name" {
  type = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
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

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}
