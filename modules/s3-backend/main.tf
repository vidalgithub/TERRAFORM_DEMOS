resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-on-aws-eks-kemgou"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Environment = "all"
    Owner       = "kemgou-tf"
  }
}

# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "my-terraform-state-locks-s3"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Environment = "all"
#     Owner       = "kemgou-tf"
#   }
# }



