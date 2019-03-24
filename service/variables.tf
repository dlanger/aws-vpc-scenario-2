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
  description = "suffix to append to the generated name (seen in the console), to describe purpose or type"
  default     = ""
}

variable "deletion_protection" {
  type        = "string"
  description = "enable deletion protection, meaning that TF would be unable to delete the ALB without you going into the web console first to unprotect this"
  default     = "false"
}

variable "log_bucket_name" {
  type        = "string"
  description = "name for the S3 bucket where logs will go"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC the security group will be in"
}

variable "public_subnets" {
  type        = "list"
  description = "list of public subnets to put the LB into, must span two or more AZs and not have more than one subnet per AZ"
}

variable "private_subnets" {
  type        = "list"
  description = "list of private subnets to put the instances into, must span two or more AZs and not have more than one subnet per AZ"
}

variable "lb_security_groups" {
  type        = "list"
  description = "list of SGs to attach to the LB (lb->instances SG will be auto-generated)"
  default     = []
}

variable "instance_security_groups" {
  type        = "list"
  description = "list of SGs to attach to the instances (lb->instances SG will be auto-generated)"
  default     = []
}

variable "server_port" {
  type        = "string"
  description = "port on which the server is running"
}

variable "external_lb_ssl_policy" {
  type        = "string"
  description = "cipher policy for external ssl connections to lb, see https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies for options"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "external_lb_ssl_certificate_arn" {
  type        = "string"
  description = "arn of the ssl certificate to use for external connections to the lb for your domain"
}

variable "idle_timeout" {
  type        = "string"
  description = "time (in seconds) that a connection can be idle before being dropped"
}

variable "healthcheck_path" {
  type        = "string"
  description = "path to the instance healthcheck"
}

variable "healthcheck_interval" {
  type        = "string"
  description = "delay between health checks"
  default     = "15"
}

variable "healthcheck_timeout" {
  type        = "string"
  description = "timeout for healthcheck response"
  default     = "10"
}

variable "healthcheck_healthy_response_range" {
  type        = "string"
  description = "range of status codes from the healthcheck to show a healthy instance"
  default     = "200-399"
}

variable "healthcheck_healthy_count" {
  type        = "string"
  description = "number of sequential healthy responses to mark an instance healthy"
  default     = "3"
}

variable "healthcheck_unhealthy_count" {
  type        = "string"
  description = "number of sequential unhealthy responses to mark an instance unhealthy"
  default     = "2"
}

variable "draining_time" {
  type        = "string"
  description = "number of seconds for to lb to allow draining requests to finish"
  default     = "60"
}

variable "warmup_time" {
  type        = "string"
  description = "number of seconds for new targets to receive an increasing % of requests, as opposed straight from 0% to a full share"
  default     = "30"
}

variable "num_instances" {
  type        = "string"
  description = "number of instances of server to run"
}

variable "instance_ready_time" {
  type        = "string"
  description = "time (in seconds) it takes for an instance to go from powered-off to ready to serve requests"
}

variable "unlimited_credits" {
  type        = "string"
  description = "credit option for burstable instances (impacts billing)"
  default     = "false"
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
