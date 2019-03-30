locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.service_name}${var.name_suffix}"
  }

  external_ssh_port = "22"
  internal_ssh_port = "22"
}

module "sg_bastion" {
  source = "../security-group"

  service_name = "${var.service_name}"
  cost_centre  = "${local.common_tags["Cost-centre"]}"
  environment  = "${local.common_tags["Environment"]}"

  vpc_id = "${var.vpc_id}"

  allowed_origins = ["${formatlist("%s:%s", var.allowed_cidrs, local.external_ssh_port)}"]
}

resource "aws_security_group_rule" "ingress_to_accessible_sgs" {
  count = "${length(var.accessible_security_groups)}"

  type                     = "ingress"
  security_group_id        = "${element(var.accessible_security_groups, count.index)}"
  source_security_group_id = "${module.sg_bastion.id}"
  from_port                = "${local.internal_ssh_port}"
  to_port                  = "${local.internal_ssh_port}"
  protocol                 = "tcp"
}

resource "aws_instance" "bastion" {
  ami = "${var.ami}"

  subnet_id                   = "${var.public_subnet}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${concat(list(module.sg_bastion.id), var.additional_security_groups)}"]
  associate_public_ip_address = "true"
  ipv6_address_count          = "0"

  key_name             = "${var.ssh_keypair_name}"
  iam_instance_profile = "${var.instance_iam_profile}"

  disable_api_termination = "false"
  monitoring              = "true"
  user_data               = "${var.user_data}"

  tags = "${local.common_tags}"
}
