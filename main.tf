module "vpc" {
  source = "git::https://github.com/SaiDevOps27/tf-module-vpc.git"
  env = var.env
  tags = var.tags
  default_route_table = var.default_route_table
  default_vpc_id = var.default_vpc_id


  for_each = var.vpc
  vpc_cidr = each.value["vpc_cidr"]
  public_subnets = each.value["public_subnets"]
  private_subnets = each.value["private_subnets"]
}



module "docdb" {
  source = "git::https://github.com/SaiDevOps27/tf-module-docdb.git"
  env = var.env
  tags = var.tags

  for_each = var.docdb
  engine = each.value["engine"]
  vpc_id = module.vpc["main"].vpc_id
  backup_retention_period = each.value["backup_retention_period"]
  preferred_backup_window = each.value["preferred_backup_window"]
  skip_final_snapshot = each.value["skip_final_snapshot"]
  engine_version = each.value["engine_version"]
  no_of_instances = each.value["no_of_instances"]
  instance_class = each.value["instance_class"]
  subnet_ids = local.db_subnet_ids
  allow_subnets = lookup(local.subnet_cidr, each.value["allow_subnets"], null)
}


module "rds" {
  source = "git::https://github.com/SaiDevOps27/tf-module-rds.git"
  env = var.env
  tags = var.tags

  for_each = var.rds
  engine = each.value["engine"]
  backup_retention_period = each.value["backup_retention_period"]
  preferred_backup_window = each.value["preferred_backup_window"]
  skip_final_snapshot = each.value["skip_final_snapshot"]
  engine_version = each.value["engine_version"]
  no_of_instances = each.value["no_of_instances"]
  instance_class = each.value["instance_class"]
  subnet_ids = local.db_subnet_ids
  vpc_id = module.vpc["main"].vpc_id
  allow_subnets = lookup(local.subnet_cidr, each.value["allow_subnets"], null)

}

module "elasticache" {
  source = "git::https://github.com/SaiDevOps27/tf-module-elasticache.git"
  env = var.env
  tags = var.tags

  for_each = var.elasticache
  engine = each.value["engine"]
  engine_version = each.value["engine_version"]
  num_cache_nodes = each.value["num_cache_nodes"]
  node_type = each.value["node_type"]
  subnet_ids = local.db_subnet_ids
  vpc_id = module.vpc["main"].vpc_id
  allow_subnets = lookup(local.subnet_cidr, each.value["allow_subnets"], null)
}


module "rabbitmq" {
  depends_on = [module.vpc]
  source = "git::https://github.com/SaiDevOps27/tf-module-rabbitmq.git"
  env = var.env
  tags = var.tags

  for_each = var.rabbitmq
  instance_type = each.value["instance_type"]
  subnet_ids = local.db_subnet_ids
  vpc_id = module.vpc["main"].vpc_id
  bastion_cidr = var.bastion_cidr
  dns_domain = var.dns_domain
  allow_subnets = lookup(local.subnet_cidr, each.value["allow_subnets"], null)

}

/*
module "alb" {
  source = "git::https://github.com/SaiDevOps27/tf-module-alb.git"
  env = var.env
  tags = var.tags
  vpc_id = module.vpc["main"].vpc_id

  for_each = var.alb
  allow_cidr = each.value["allow_cidr"]
  name = each.value["name"]
  internal = each.value["internal"]
  load_balancer_type = each.value["load_balancer_type"]
  subnets = lookup(local.subnet_ids, each.value["subnet_name"], null)
}


module "app" {
  source = "git::https://github.com/SaiDevOps27/tf-module-app.git"
  env = var.env
  tags = var.tags
  vpc_id = module.vpc["main"].vpc_id
  bastion_cidr = var.bastion_cidr
  depends_on = [module.vpc, module.docdb, module.rds, module.elasticache, module.rabbitmq, module.alb]
  dns_domain = var.dns_domain

  for_each = var.apps
  component = each.value["component"]
  instance_type = each.value["instance_type"]
  desired_capacity = each.value["desired_capacity"]
  max_size = each.value["max_size"]
  monitoring_nodes = var.monitoring_nodes
  min_size = each.value["min_size"]
  parameters = each.value["parameters"]
  subnets = lookup(local.subnet_ids, each.value["subnet_name"], null)
  port = each.value["port"]
  listener_priority = each.value["listener_priority"]
  allow_app_to = lookup(local.subnet_cidr, each.value["allow_app_to"], null)
  alb_dns_name = lookup(lookup(lookup(module.alb, each.value["alb"], null), "alb", null), "dns_name", null)
  listener_arn = lookup(lookup(lookup(module.alb, each.value["alb"], null), "listener", null), "arn", null)

}

output "alb" {
  value = module.elasticache
}

## LOAD RUNNER


resource "aws_instance" "load-runner" {
  ami                    = "ami-048e6af195c73e7b2"
  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-0a83e7cd1f994b2a4"]

  tags = merge(
    var.tags,
    { Name = "load-runner" }
  )
}

resource "aws_ec2_tag" "name-tag" {
  key         = "Name"
  resource_id = aws_instance.load-runner.id
  value       = "load-runner"
}

resource "null_resource" "load-gen" {
  triggers = {
    abc = aws_instance.load-runner.public_ip
  }
  provisioner "remote-exec" {
    connection {
      host     = aws_instance.load-runner.public_ip
      user     = "root"
      password = data.aws_ssm_parameter.ssh_pass.value
    }
    inline = [
      "curl -s -L https://get.docker.com | bash",
      "systemctl enable docker",
      "systemctl start docker",
      "docker pull robotshop/rs-load"
    ]
  }
}




module "minikube" {
  source = "github.com/scholzj/terraform-aws-minikube"

  aws_region          = "us-east-1"
  cluster_name        = "minikube"
  aws_instance_type   = "t3.medium"
  ssh_public_key      = "~/.ssh/id_rsa.pub"
  aws_subnet_id       = lookup(local.subnet_ids, "public", null)[0]
  hosted_zone         = "devopsb.cloud"
  hosted_zone_private = false

  tags = {
    Name = "Minikube"
  }

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/heapster.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml"
  ]
}


output "MINIKUBE_SERVER" {
  value = "ssh centos@${module.minikube.public_ip}"
}

output "KUBE_CONFIG" {
  value = "scp centos@${module.minikube.public_ip}:/home/centos/kubeconfig ~/.kube/config"
}
*/

module "eks" {
  source             = "github.com/r-devops/tf-module-eks"
  ENV                = var.env
  PRIVATE_SUBNET_IDS = lookup(local.subnet_ids, "app", null)
  PUBLIC_SUBNET_IDS  = lookup(local.subnet_ids, "public", null)
  DESIRED_SIZE       = 1
  MAX_SIZE           = 1
  MIN_SIZE           = 1
}

