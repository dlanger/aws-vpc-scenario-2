resource "aws_lb" "external" {
  load_balancer_type = "application"
  name               = "${local.common_tags["Name"]}"
  internal           = "false"

  security_groups = ["${concat(var.lb_security_groups, list(module.sg_lb_to_instances.id))}"]
  subnets         = ["${var.public_subnets}"]

  idle_timeout                     = "${var.idle_timeout}"
  enable_deletion_protection       = "${var.deletion_protection}"
  enable_cross_zone_load_balancing = "true"
  enable_http2                     = "true"
  ip_address_type                  = "ipv4"

  access_logs {
    enabled = true
    bucket  = "${var.log_bucket_name}"
    prefix  = "${local.common_tags["Name"]}-"
  }

  tags = "${local.common_tags}"
}

resource "aws_lb_listener" "external_https" {
  load_balancer_arn = "${aws_lb.external.id}"
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "${var.external_lb_ssl_policy}"
  certificate_arn = "${var.external_lb_ssl_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.server.arn}"
  }
}

resource "aws_lb_listener" "external_http" {
  load_balancer_arn = "${aws_lb.external.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      port        = "80"
    }
  }
}

resource "aws_lb_target_group" "server" {
  vpc_id = "${var.vpc_id}"
  name   = "${local.common_tags["Name"]}"

  port     = "${var.server_port}"
  protocol = "HTTP"

  deregistration_delay = "${var.draining_time}"
  slow_start           = "${var.warmup_time}"

  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = "${var.healthcheck_path}"
    port                = "${var.server_port}"
    interval            = "${var.healthcheck_interval}"
    timeout             = "${var.healthcheck_timeout}"
    healthy_threshold   = "${var.healthcheck_healthy_count}"
    unhealthy_threshold = "${var.healthcheck_unhealthy_count}"
    matcher             = "${var.healthcheck_healthy_response_range}"
  }

  stickiness {
    enabled         = "true"
    type            = "lb_cookie"
    cookie_duration = "${60 * 60 * 6}"
  }

  lifecycle {
    create_before_destroy = "true"
  }

  depends_on = ["aws_lb.external"]

  tags = "${local.common_tags}"
}

resource "aws_lb_listener_certificate" "server" {
  listener_arn    = "${aws_lb_listener.external_https.arn}"
  certificate_arn = "${var.external_lb_ssl_certificate_arn}"
}
