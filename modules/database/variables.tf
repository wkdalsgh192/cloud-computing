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
  type = number
}

variable "db_password" {
  type = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "data_sg_id" {
  type = string
}

variable "data_subnets_by_az" {
  type = map(string)
}