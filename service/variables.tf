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

variable "deletion_protection" {
  type        = "string"
  description = "enable deletion protection, meaning that TF would be unable to delete the ALB without you going into the web console first to unprotect this"
  default     = "false"
}

variable "idle_timeout" {
  type        = "string"
  description = "time (in seconds) that a connection can be idle before being dropped"
}

variable "log_bucket_name" {
  type        = "string"
  description = "name for the S3 bucket where logs will go"
}

variable "public_subnets" {
  type        = "list"
  description = "list of public subnets to put the LB into, must span two or more AZs"
}

variable "lb_security_groups" {
  type        = "list"
  description = "list of SGs to attach to the LB"
  default     = []
}

variable "instance_security_groups" {
  type        = "list"
  description = "list of SGs to attach to the instances"
  default     = []
}

variable "healthcheck" {
  type        = "string"
  description = "path to the instance healthcheck"
}
