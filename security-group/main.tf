locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.service_name}${var.name_suffix}"
  }
}

resource "aws_security_group" "this" {
  vpc_id = "${var.vpc_id}"

  name_prefix = "${local.common_tags["Name"]}-"

  tags = "${local.common_tags}"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = "${aws_security_group.this.id}"

  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_cidrs" {
  count = "${length(var.allowed_origins)}"

  type              = "ingress"
  security_group_id = "${aws_security_group.this.id}"

  cidr_blocks = ["${element(split(":", element(var.allowed_origins, count.index)), 0)}"]
  from_port   = "${element(split(":", element(var.allowed_origins, count.index)), 1)}"
  to_port     = "${element(split(":", element(var.allowed_origins, count.index)), 1)}"
  protocol    = "tcp"
}

resource "aws_security_group_rule" "ingress_sgs" {
  count = "${length(var.allowed_sgs)}"

  type              = "ingress"
  security_group_id = "${aws_security_group.this.id}"

  source_security_group_id = "${element(split(":", element(var.allowed_sgs, count.index)), 0)}"
  from_port                = "${element(split(":", element(var.allowed_sgs, count.index)), 1)}"
  to_port                  = "${element(split(":", element(var.allowed_sgs, count.index)), 1)}"
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "ingress_mutual" {
  count = "${length(var.allowed_mutual_ports)}"

  type              = "ingress"
  security_group_id = "${aws_security_group.this.id}"

  self      = "true"
  from_port = "${element(var.allowed_mutual_ports, count.index)}"
  to_port   = "${element(var.allowed_mutual_ports, count.index)}"
  protocol  = "tcp"
}
