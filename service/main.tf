locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.service_name}${var.name_suffix}"
  }
}

module "sg_lb_to_instances" {
  source = "../security-group"

  service_name = "${local.common_tags["Service"]}"
  name_suffix  = "-lb-link"
  cost_centre  = "${local.common_tags["Cost-centre"]}"
  environment  = "${local.common_tags["Environment"]}"

  vpc_id = "${var.vpc_id}"

  allowed_mutual_ports = ["${var.server_port}"]
}
