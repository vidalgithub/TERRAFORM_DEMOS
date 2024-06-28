variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "kemgou-eks-vpc"
}

variable "newbits" {
  default = 8
}

variable "public_subnet_count" {
  default = 2
}

variable "eks_private_subnet_count" {
  default = 2
}

variable "db_private_subnet_count" {
  default = 2
}
variable "azs_count" {
  default = 3
}

/* variable "prefix" {
  default = "kemgou"
} */



variable "common_tags" {
  type = map(any)
  default = {
    "AssetID"       = "kemgou"
    "AssetName"     = "Insfrastructure"
    "AssetAreaName" = "ADL"
    "ControlledBy"  = "Terraform"
    "cloudProvider" = "aws"
    "Environment"   = "dev"
    "Project"       = "delta"
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}
