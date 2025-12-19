variable "vpc_id" {
  type = string
}

variable "db_port" {
  type = number
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "app_subnet_cidrs" {
  type = list(string)
}

variable "data_subnet_cidrs" {
  type = list(string)
}

variable "public_subnets_by_az" {
  type = map(string)
}

variable "private_subnets_by_az" {
  type = map(string)
}

variable "data_subnets_by_az" {
  type = map(string)
}