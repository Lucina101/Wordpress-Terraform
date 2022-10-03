"# Wordpress-Terraform" 

Deploy wordpress site with terraform and aws services.
This infrastructure is not free though. I used one forced-paid service, NAT-gateway. (Since I was forced by instructor to use it)
\n
Apart form NAT gateway, most of things should be covered by aws free-tier to some extent. Using two instances will exceed monthly free for sure if they're active for too long.
Do not run it for fun if you do not want to pay or change NAT gateway to normal internet gateway first.
\n
It's just simple wordpress site hosting by two ec2 instances, one for databases and one for app.
There is also plugin for s3 to upload media. Everything is newly created in this script, no import.
\n
Some services might not be necessary, for example, S3, IAM_user and using two instances.
This is just for my assignment, so it might not be good if you're going to host real website for some purposes.