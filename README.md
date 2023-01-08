# Wordpress-Terraform

Deploy wordpress site with terraform and aws services.
This infrastructure is not free though. I used one forced-paid service, NAT-gateway. (Since it's the requirement given by instructor for this project.)

Apart form NAT gateway, most of things should be covered by aws free-tier to some extent. Using two instances will exceed monthly free-tier for sure if they're active for too long.
Do not run it for fun if you do not want to lose money or change NAT gateway to normal internet gateway before running.

This is simple wordpress site hosting by two ec2 instances, one for database and another for app.
There is also plugin for s3 to upload media. Everything are newly created in this script, no import is required.

# Deployment

Clone this repository. Make sure terraform is installed and aws credential is in ~/.aws

Run this command
```bash
  terraform apply
```

To clean up created resources, run
```bash
  terraform destroy
```
