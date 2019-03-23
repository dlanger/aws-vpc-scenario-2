output "app1_lb_dns_name" {
  value = "${module.service_app1.lb_dns_name}"
}

output "app1_lb_arn" {
  value = "${module.service_app1.lb_arn}"
}
