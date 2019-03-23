output "lb_dns_name" {
  value = "${aws_lb.external.dns_name}"
}

output "lb_arn" {
  value = "${aws_lb.external.arn}"
}
