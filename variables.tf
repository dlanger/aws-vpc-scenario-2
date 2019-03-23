variable "environment" {
  type        = "string"
  description = "environment this is being deployed into"
}

variable "log_bucket_name" {
  type        = "string"
  description = "name of the S3 bucket to store LB access logs in"
}
