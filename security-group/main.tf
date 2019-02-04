locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.service_name}"
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
  count = "${length(var.allowed_cidrs) > 0 ? length(var.allowed_ports) : 0}"

  type              = "ingress"
  security_group_id = "${aws_security_group.this.id}"

  cidr_blocks = ["${var.allowed_cidrs}"]
  from_port   = "${element(var.allowed_ports, count.index)}"
  to_port     = "${element(var.allowed_ports, count.index)}"
  protocol    = "tcp"
}

resource "aws_security_group_rule" "ingress_sgs" {
  count = "${length(var.allowed_sgs) > 0 ? length(var.allowed_sgs) * length(var.allowed_ports) : 0}"

  type              = "ingress"
  security_group_id = "${aws_security_group.this.id}"

  source_security_group_id = "${element(var.allowed_sgs, count.index)}"
  from_port                = "${element(var.allowed_ports, count.index)}"
  to_port                  = "${element(var.allowed_ports, count.index)}"
  protocol                 = "tcp"
}
