
## Requirements

You'll need to create the following AWS objects manually:

|Object|Used later as|
|------|--------------|
|An S3 bucket to be used for ALB logs, configured with [these](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions) permissions| `log_bucket_name`| 
|An ACM certificate for your external load balancer(s)|`external_lb_ssl_certificate_arn`|
|An AMI, described as below |`service_app1.ami`|

Ensure all variables defined in `scenario-2.tf/locals` are either [defined](https://learn.hashicorp.com/terraform/getting-started/variables) or hardcoded in the file. 

You should also review the values in `scenario-2.tf`, and the additional possible ones in the modules' `variables.tf`.

You will need your own AMI for `service_app1.ami` - when done booting, it should serve a `200` response on `service_app1.server_port` at path `service_app1.healthcheck_path`. Terraform is set to wait for the app servers to come up, so your stack will not finish applying if your AMI doesn't work do this.

## Deploying

1. Set the appropriate values in `scenario-2.tf/locals`
1. Set an AMI in `service_app1.ami`
1. `terraform plan`
1. `terraform apply`

## Testing

When your stack deploys successfully, you can test it with `curl`:
```bash
$ curl https://<outputs.app1_lb_dns_name> --insecure
```
We need `--insecure` as this stack doesn't set up DNS for your load-balancer, and whatever domain you put on the ACM certificate you set doesn't cover `*.elb.amazonaws.com`.
