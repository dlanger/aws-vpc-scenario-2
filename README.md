
## Requirements

You'll need to create the following AWS objects manually:

||Object||Used later as||
|An S3 bucket to be used for ALB logs, configured with [these](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions) permissions| `log_bucket_name`| 
|An ACM certificate for your external load balancer(s)|`external_lb_ssl_certificate_arn`|

Ensure all variables defined in `scenario-2.tf/locals` are either [defined](https://learn.hashicorp.com/terraform/getting-started/variables) or hardcoded in the file. 

