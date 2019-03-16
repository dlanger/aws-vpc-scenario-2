locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.service_name}${var.name_suffix}"
  }
}

resource "aws_lb" "this" {
  load_balancer_type = "application"
  name               = "${local.common_tags["Name"]}"
  internal           = "false"

  security_groups = ["${concat(var.lb_security_groups, list(module.lb_to_instances_sg.id))}"]
  subnets         = ["${var.public_subnets}"]
  idle_timeout    = "${var.idle_timeout}"

  enable_deletion_protection       = "${var.deletion_protection}"
  enable_cross_zone_load_balancing = "true"
  enable_http2                     = "true"
  ip_address_type                  = "ipv4"

  access_logs {
    enabled = true
    bucket  = "${var.log_bucket_name}"
    prefix  = "${local.common_tags["Name"]}"
  }

  tags = "${local.common_tags}"
}

module "lb_to_instances_sg" {
  source = "../security-group"

  service_name = "${local.common_tags["Service"]}"
  name_suffix  = "-lb-link"
  cost_centre  = "${local.common_tags["Cost-centre"]}"
  environment  = "${local.common_tags["Environment"]}"

  vpc_id = "${var.vpc_id}"

  allowed_mutual_ports = ["${var.server_port}"]
}
