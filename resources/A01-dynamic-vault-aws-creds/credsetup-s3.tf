provider "vault" {}
# First, set Vault server and token as env variables - see script.sh 

# Enable aws secrets engine in Vault & credentials for Vault to communicate with AWS with IAM policy so it can create IAM User and credentials.
resource "vault_aws_secret_backend" "aws" {
  access_key = "" #var.aws_access_key
  secret_key = "" #var.aws_secret_key

  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds = "240"
}

# Create a role in Vault which will map to AWS credentials generated - means it should have the proper permisions 
# required to the temporary IAM User to vision the infrastructure in the configuration file.
resource "vault_aws_secret_backend_role" "admin" {
  backend          = vault_aws_secret_backend.aws.path
  name             = "demorole"
  credential_type  = "iam_user"

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "dynamodb:*",
        "iam:*"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

output "backend" {
    value = vault_aws_secret_backend.aws.path
}

output "role" {
    value = vault_aws_secret_backend_role.admin.name
}

# generally, these blocks would be in a different module

# data "vault_aws_access_credentials" "creds" {
#   backend = vault_aws_secret_backend.aws.path
#   role    = vault_aws_secret_backend_role.admin.name
# }

# provider "vault" {
#   address = "http://172.25.11.223:8200"
# }