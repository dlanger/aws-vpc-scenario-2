locals {
  common_tags = {
    Cost-centre = "${var.cost_centre}"
    Service     = "${var.service_name}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.service_name}${var.name_suffix}"
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${coalesce(var.profile_name, local.common_tags["Name"])}"
  role = "${aws_iam_role.this.name}"
}

resource "aws_iam_role" "this" {
  name               = "${coalesce(var.role_name, local.common_tags["Name"])}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.instance_assume_role.json}"

  tags = "${local.common_tags}"
}

data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "this" {
  count  = "${length(var.policy_document) > 0 ? 1 : 0}"
  name   = "${var.profile_name}"
  role   = "${aws_iam_role.this.id}"
  policy = "${var.policy_document}"
}
