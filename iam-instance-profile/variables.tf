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

variable "profile_name" {
  type        = "string"
  description = "name for the profile (overriding the standard name)"
  default     = ""
}

variable "role_name" {
  type        = "string"
  description = "name for the role (overriding the standard name)"
  default     = ""
}

variable "role_path" {
  type        = "string"
  description = "path in which to create the underlying role"
  default     = "/"
}

variable "policy_document" {
  type        = "string"
  description = "JSON IAM policy document to attach to the underlying role"
  default     = "default_value"
}
