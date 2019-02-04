variable "vpc_cidr" {
  type = "string"
}

variable "assign_ipv6_ips" {
  type    = "string"
  default = "false"
}

variable "private_subnets" {
  type        = "list"
  description = "CIDRs of the private subnets to create"
}

variable "public_subnets" {
  type        = "list"
  description = "CIDRs of the public subnets to create"
}

variable "azs" {
  type        = "list"
  description = "list of azs to spread instances over"
}

variable "nat_per_az" {
  type        = "string"
  description = "use one NAT gateway per AZ, as opposed to one NAT gateway per VPC"
}

variable "cost_centre" {
  type        = "string"
  description = "value for the Cost-centre tag to be applied to all resources"
}

variable "service_name" {
  type        = "string"
  description = "value for the Service tag to be applied to all resources"
}

variable "environment" {
  type        = "string"
  description = "environment this is being deployed into"
}
