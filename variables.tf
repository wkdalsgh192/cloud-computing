variable "region" {
  default = "us-west-2"
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