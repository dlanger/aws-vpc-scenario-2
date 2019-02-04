locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.service_name}"
  }
}

resource "aws_lb" "this" {
  load_balancer_type = "application"
  name               = "${local.common_tags["Name"]}"
  internal           = "false"

  security_groups = ["${var.lb_security_groups}"]
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

# modify instance SGs passed in to allow connections from the LB

