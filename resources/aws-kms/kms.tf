provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "primary" {
  description             = "Primary KMS Key in us-east-1"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = true # This is essential to make the key a multi-Region key
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::262485716661:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Alias for primary key
resource "aws_kms_alias" "primary_alias" {
  name          = "alias/my-primary-key"
  target_key_id = aws_kms_key.primary.key_id
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

# resource "aws_kms_replica_key" "us_west_2" {
#   provider             = aws.us-west-2
#   description          = "Replica KMS Key in us-west-2"
#   primary_key_arn      = aws_kms_key.primary.arn
#   policy               = aws_kms_key.primary.policy
# }

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

# resource "aws_kms_replica_key" "eu_central_1" {
#   provider             = aws.eu-central-1
#   description          = "Replica KMS Key in eu-central-1"
#   primary_key_arn      = aws_kms_key.primary.arn
#   policy               = aws_kms_key.primary.policy
# }
