module "network" {
  source = "../../modules/network"

  vpc_cidr            = var.vpc_cidr
  azs                 = local.azs
  public_subnet_cidrs = local.public_subnet_cidrs
  app_subnet_cidrs    = local.app_subnet_cidrs
  data_subnet_cidrs   = local.data_subnet_cidrs
}

module "security" {
  source = "../../modules/security"

  vpc_id                = module.network.vpc_id
  db_port               = var.db_port
  public_subnet_cidrs   = local.public_subnet_cidrs
  app_subnet_cidrs      = local.app_subnet_cidrs
  data_subnet_cidrs     = local.data_subnet_cidrs
  public_subnets_by_az  = module.network.public_subnets_by_az
  private_subnets_by_az = module.network.private_subnets_by_az
  data_subnets_by_az    = module.network.data_subnets_by_az
}

module "compute" {
  source                = "../../modules/compute"
  key_name              = aws_key_pair.ec2_keypair.key_name
  bastion_sg_id         = module.security.public_ssh_sg_id
  app_sg_id             = module.security.private_app_sg_id
  public_subnets_by_az  = module.network.public_subnets_by_az
  private_subnets_by_az = module.network.private_subnets_by_az
}

module "database" {
  source             = "../../modules/database"
  db_port            = var.db_port
  db_password        = var.db_password
  data_subnets_by_az = module.network.data_subnets_by_az
  data_sg_id         = module.security.data_sg_id
}
