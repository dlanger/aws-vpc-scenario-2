locals {
  environment     = "stage"
  log_bucket_name = "dlanger-test-logs"
}

module "network" {
  source = "./vpc-networking"

  service_name = "common"
  cost_centre  = "infrastructure"
  environment  = "${local.environment}"

  vpc_cidr        = "10.100.0.0/16"
  azs             = ["us-east-2a", "us-east-2b"]
  public_subnets  = ["10.100.21.0/24", "10.100.22.0/24", "10.100.23.0/24"]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]

  assign_ipv6_ips = "false"
  nat_per_az      = "false"
}

module "sg_all_apps_external" {
  source = "./security-group"

  service_name = "common"
  cost_centre  = "infrastructure"
  environment  = "${local.environment}"

  vpc_id        = "${module.network.vpc_id}"
  allowed_cidrs = ["0.0.0.0/0"]
  allowed_ports = ["80", "443"]
}

module "sg_app1_internal" {
  source = "./security-group"

  service_name = "app1"
  cost_centre  = "app1"
  environment  = "${local.environment}"

  vpc_id        = "${module.network.vpc_id}"
  allowed_sgs   = ["${module.sg_all_apps_external.id}"]
  allowed_ports = ["8000"]
}

module "service" {
  source = "./service"

  service_name = "app1-web"
  cost_centre  = "app1"
  environment  = "${local.environment}"

  public_subnets           = "${module.network.public_subnet_ids}"
  lb_security_groups       = ["${module.sg_all_apps_external.id}"]
  instance_security_groups = ["${module.sg_app1_internal.id}"]

  healthcheck  = "/healthcheck"
  idle_timeout = "60"

  deletion_protection = "false"
  log_bucket_name     = "${local.log_bucket_name}"
}
