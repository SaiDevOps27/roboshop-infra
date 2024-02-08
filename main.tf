module "vpc" {
  source = "git::https://github.com/SaiDevOps27/tf-module-vpc.git"
  env = var.env
  for_each = var.vpc
  vpc_cidr = each.value["vpc_cidr"]
}

