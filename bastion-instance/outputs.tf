output "security_group_id" {
  value = "${module.sg_bastion.id}"
}

output "public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
