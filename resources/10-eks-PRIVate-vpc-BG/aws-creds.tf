############# CONNECT AND GENERATE TEMPORARY AWS CREDENTIALS ################
# provider "vault" {
#     address = "http://vault.beitcloud.com:8200"
# }

provider "vault" {}
# First, set Vault server and token as env variables - see script.sh

variable "cred_backend" {
  default = "aws-admin-backend"

}

variable "cred_role_name" {
  default = "aws-admin-role"
}

# Generate Dynamic AWS credentials
data "vault_aws_access_credentials" "creds" {
  backend = var.cred_backend  # vault_aws_secret_backend.aws.path
  role    = var.cred_role_name  #vault_aws_secret_backend_role.role.name
}

# Use the generated Dynamic AWS credentials (from data block) connect to AWS backend platform and provision/create your infrastruture
provider "aws" {
  region     = "us-east-1"
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

