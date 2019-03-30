variable "cost_centre" {
  type        = "string"
  description = "value for the Cost-centre tag to be applied to all resources"
}

variable "service_name" {
  type        = "string"
  description = "value for the Service tag to be applied to all resources"
  default     = "bastion"
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

variable "instance_iam_profile" {
  type        = "string"
  description = "name of IAM profile to apply to the instances"
  default     = ""
}

variable "ami" {
  type        = "string"
  description = "ami to deploy"
}

variable "instance_type" {
  type        = "string"
  description = "instance type to deploy"
}

variable "ssh_keypair_name" {
  type        = "string"
  description = "AWS name of the SSH keypair to bake into the instances"
  default     = ""
}

variable "user_data" {
  type        = "string"
  description = "user_data to inject into the instance on boot by cloud-init"
  default     = ""
}

variable "public_subnet" {
  type        = "string"
  description = "ID of the public subnet this server should go into"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC this server should go into"
}

variable "allowed_cidrs" {
  type        = "list"
  description = "list of CIDRs that connections can come from"
  default     = []
}

variable "accessible_security_groups" {
  type        = "list"
  description = "list of security group IDs which this instance can SSH to"
  default     = []
}

variable "additional_security_groups" {
  type        = "list"
  description = "addtional security groups which this instance should be a member of, beyond the auto-generated one"
  default     = []
}
