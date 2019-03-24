locals {
  environment                     = "stage"
  log_bucket_name                 = "${var.log_bucket_name}"
  external_lb_ssl_certificate_arn = "${var.external_lb_ssl_certificate_arn}"
}

module "network" {
  source = "./vpc-networking"

  service_name = "common"
  cost_centre  = "infrastructure"
  environment  = "${local.environment}"

  vpc_cidr        = "10.100.0.0/16"
  azs             = ["us-east-2a", "us-east-2b"]
  public_subnets  = ["10.100.21.0/24", "10.100.22.0/24"]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24"]

  assign_ipv6_ips = "false"
  nat_per_az      = "false"
}

module "sg_external_lb" {
  source = "./security-group"

  service_name = "common"
  cost_centre  = "infrastructure"
  environment  = "${local.environment}"

  vpc_id = "${module.network.vpc_id}"

  allowed_cidrs = [
    "0.0.0.0/0:80",
    "0.0.0.0/0:443",
  ]
}

module "sg_internal_all_instances" {
  source = "./security-group"

  service_name = "common"
  name_suffix  = "-internal"
  cost_centre  = "infrastructure"
  environment  = "${local.environment}"

  vpc_id = "${module.network.vpc_id}"
}

module "iam_profile_app1" {
  source          = "./iam-instance-profile"
  policy_document = ""

  service_name = "app1"
  cost_centre  = "app1"
  environment  = "${local.environment}"
}

module "service_app1" {
  source = "./service"

  instance_type = "t3.small"
  ami           = "ami-00c5940f2b52c5d98"

  service_name = "app1"
  name_suffix  = "-web"
  cost_centre  = "app1"
  environment  = "${local.environment}"

  vpc_id                          = "${module.network.vpc_id}"
  public_subnets                  = "${module.network.public_subnet_ids}"
  private_subnets                 = "${module.network.private_subnet_ids}"
  external_lb_ssl_certificate_arn = "${local.external_lb_ssl_certificate_arn}"
  instance_iam_profile            = "${module.iam_profile_app1.profile_name}"
  lb_security_groups              = ["${module.sg_external_lb.id}"]
  instance_security_groups        = ["${module.sg_internal_all_instances.id}"]

  num_instances       = "3"
  server_port         = "8000"
  healthcheck_path    = "/"
  idle_timeout        = "60"
  instance_ready_time = "90"

  deletion_protection = "false"
  log_bucket_name     = "${local.log_bucket_name}"
}
