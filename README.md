AWS' [VPC Scenario 2](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html), implemented in Terraform.

This builds a system containing:
* Auto-scaled instances spanning two availability zones, behind an application load balancer
* Routing set so that the instances don't have public IP addresses, and all outbound traffic is routed through a NAT gateway (either one per environment, or one per availability zone)
* An SSH [bastion host](https://en.wikipedia.org/wiki/Bastion_host) with a public IP, which you can connect to and then from there connect to the private instances
* Consistent resource tagging & naming, designed to support easy budget management and a pleasant console experience 

These are delivered using a series of Terraform modules with sensible defaults, to make it easier to expand the system. 

Take a look at `scenario-2.tf`, and go from there.

## Requirements

You'll need to create the following AWS objects manually:

|Object|Used later as|
|------|--------------|
|An S3 bucket to be used for ALB logs, configured with [these](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions) permissions| `log_bucket_name`| 
|An ACM certificate for your external load balancer(s)|`external_lb_ssl_certificate_arn`|
|An AMI, described as below |`service_app1.ami`|

Ensure all variables defined in `scenario-2.tf/locals` are either [defined](https://learn.hashicorp.com/terraform/getting-started/variables) or hardcoded in the file. 

You should also review the values in `scenario-2.tf`, and the additional possible ones in the modules' `variables.tf`.

You'll need your own AMI for `service_app1.ami` - when done booting, it should serve a `200` response on `service_app1.server_port` at path `service_app1.healthcheck_path`. Terraform is set to wait for the app servers to come up, so your stack won't finish applying if your AMI doesn't do this.

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

## Production Use

This stack is usable for microservice-based production use as-is. 

If I were using it for a longer time, some enhancements I'd consider:

* [Automatically installing](https://aws.amazon.com/blogs/security/how-to-record-ssh-sessions-established-through-a-bastion-host/) SSH keys onto all instances
* Adding [DNS](https://www.terraform.io/docs/providers/aws/r/route53_record.html) for each load-balancer
* Moving the bastion into an autoscaling group of one, and use something [like this](https://gist.github.com/hsiboy/2c3cf69d23a6335926e9193a58b49639) to update Route53 when the instance gets cycled
* Modify the `service` module to support internal-only load balancers
* Modify the `service` module to use only one ALB, and then use [path-based routing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/tutorial-load-balancer-routing.html) to send the request to the right target group
* Adding a script to the bastion instance that sets up the SSH `hosts` file with appropriate servers for the instances in the auto-scaling groups 

To add a second microservice, add another `service` [module](https://github.com/dlanger/aws-vpc-scenario-2/blob/b7cf8ebc1fe324e7852415e81fb47f5b415aae78/scenario-2.tf#L78-L105).
