# main.tf
module "networking" {
  source = "./modules/networking"

  vpc_id                 = var.vpc_id
  public_subnet_ids      = var.public_subnet_ids
  private_subnet_ids     = var.private_subnet_ids
  private_route_table_id = "rtb-00a0902328fdb2b58"
  project_name           = var.project_name
  environment            = var.environment
}

module "eks" {
  source = "./modules/eks"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  cluster_name       = "${var.project_name}-${var.environment}"
  environment        = var.environment
  project_name       = var.project_name

  depends_on = [module.networking]
}

module "gitlab" {
  source = "./modules/gitlab"

  vpc_id       = var.vpc_id
  subnet_id    = var.private_subnet_ids[0]
  environment  = var.environment
  project_name = var.project_name
  key_name     = var.key_name

  depends_on = [module.networking]
}

