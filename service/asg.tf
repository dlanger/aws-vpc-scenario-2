resource "aws_autoscaling_group" "server" {
  /* 
    We interpolate the ID and the version of the launch template into 
    the name of this autoscaling group, which ensures that the ASG will
    get re-created if the launch template is changed (since you can't edit
    the name of an existing ASG). This causes new instances using the new launch
    template to be spun up immediately, as opposed to only when an existing
    instance dies.

    This is an updated version of the strategy from 
    https://groups.google.com/forum/#!msg/terraform-tool/7Gdhv1OAc80/iNQ93riiLwAJ, 
    but using launch templates vs. configurations. 
  */

  name = "${local.common_tags["Name"]}--${aws_launch_template.server.id}--${aws_launch_template.server.latest_version}"

  vpc_zone_identifier  = ["${var.private_subnets}"]
  termination_policies = ["OldestInstance"]
  target_group_arns    = ["${aws_lb_target_group.server.arn}"]
  metrics_granularity  = "1Minute"

  max_size                  = "${var.num_instances * 2}"
  min_size                  = "${var.num_instances}"
  desired_capacity          = "${var.num_instances}"
  min_elb_capacity          = "${var.num_instances}"
  wait_for_capacity_timeout = "${var.instance_ready_time * 3}s"
  wait_for_elb_capacity     = "${var.num_instances}"
  default_cooldown          = "${var.instance_ready_time}"

  health_check_grace_period = "${var.instance_ready_time}"
  health_check_type         = "ELB"

  launch_template {
    id      = "${aws_launch_template.server.id}"
    version = "$$Latest"
  }

  tags = ["${list(
    map("key", "Cost-centre", "value", "${local.common_tags["Cost-centre"]}", "propagate_at_launch", "true"),
    map("key", "Service", "value", "${local.common_tags["Service"]}", "propagate_at_launch", "true"),
    map("key", "Environment", "value", "${local.common_tags["Environment"]}", "propagate_at_launch", "true"),
    map("key", "Name", "value", "${local.common_tags["Name"]}", "propagate_at_launch", "true")
  )}"]

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_launch_template" "server" {
  name_prefix = "${local.common_tags["Name"]}-"

  image_id               = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.ssh_keypair_name}"
  vpc_security_group_ids = ["${concat(var.instance_security_groups, list(module.sg_lb_to_instances.id))}"]
  user_data              = "${var.user_data}"

  credit_specification {
    cpu_credits = "${var.unlimited_credits ? "unlimited" : "standard"}"
  }

  iam_instance_profile {
    name = "${var.instance_iam_profile}"
  }

  monitoring {
    enabled = "true"
  }

  tags = "${local.common_tags}"

  tag_specifications {
    resource_type = "instance"
    tags          = "${local.common_tags}"
  }
}
