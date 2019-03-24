variable "log_bucket_name" {
  type        = "string"
  description = "name of the S3 bucket to store LB access logs in"
  default     = ""
}

variable "external_lb_ssl_certificate_arn" {
  type        = "string"
  description = "arn of the ACM certificate to use for external LBs"
  default     = ""
}
