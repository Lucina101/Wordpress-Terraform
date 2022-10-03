resource "aws_iam_user" "s3_user" {
  name = "s3_user"
}

resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name = "s3_user_policy"
  user = aws_iam_user.s3_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "wordpressbucket"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}
