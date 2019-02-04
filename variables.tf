variable "vpc_cidr" {
  type = "string"
}

variable "assign_ipv6_ips" {
  type    = "string"
  default = "false"
}

variable "environment" {
  type = "string"
}

variable "num_subnets" {
  type        = "string"
  description = "number of pairs of public & private subnets"
  default     = "3"
}

variable "azs" {
  type        = "list"
  description = "list of azs to spread instances over"
}
