# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-aws-eks-kemgou"
    key    = "dev/eks-cluster/terraform.tfstate"
    # key    = "dev/eks-cluster/blue-green/eks.tfstate"
    region = "us-east-1"

    # For State Locking
    dynamodb_table = "dev-ekscluster"
  }
}

############# CONNECT AND GENERATE TEMPORARY AWS CREDENTIALS ################
provider "vault" {
    address = "http://vault.beitcloud.com:8200"
}

#provider "vault" {}
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

# Terraform Provider Block
# Use the generated Dynamic AWS credentials (from data block) connect to AWS backend platform and provision/create your infrastruture
provider "aws" {
  region = var.aws_region
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

