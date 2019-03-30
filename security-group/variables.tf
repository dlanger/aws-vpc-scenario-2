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

variable "name_suffix" {
  type        = "string"
  description = "suffix to append to the generated name (seen in the console), to describe purpose"
  default     = ""
}

variable "allowed_origins" {
  type        = "list"
  description = "list of CIDR:port pairs to allow ingress from"
  default     = []
}

variable "allowed_sgs" {
  type        = "list"
  description = "list of security-group:port pairs to allow ingress from"
  default     = []
}

variable "allowed_mutual_ports" {
  type        = "list"
  description = "list of ports to allow ingress on from within the SG"
  default     = []
}

variable "vpc_id" {
  type        = "string"
  description = "VPC the security group will be in"
}
