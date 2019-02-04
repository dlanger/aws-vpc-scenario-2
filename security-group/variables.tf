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

variable "allowed_cidrs" {
  type        = "list"
  description = "list of CIDRs to allow ingress from"
  default     = []
}

variable "allowed_sgs" {
  type        = "list"
  description = "list of security groups to allow ingress from"
  default     = []
}

variable "allowed_ports" {
  type        = "list"
  description = "list of ports to allow ingress on"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC the security group will be in"
}
