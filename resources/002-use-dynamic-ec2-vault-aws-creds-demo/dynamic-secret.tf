############# CONNECT AND GENERATE AWS CREDS ################
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

# Use the generated Dynamic AWS credentials (from data block) connect to AWS backend platform and provision/create your infrastruture
provider "aws" {
  region     = "us-east-1"
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}



######## PROVISION INFRASTRUCTURE  #################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# provisdion and EC2 instance
resource "aws_instance" "aws-admin-vault" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "aws-admin-vault"
  }
}

# Create a user using the dynamic AWS credentials generated
resource "aws_iam_user" "aws-admin-vault" {
  name = "aws-admin-vault"
}

# Create an s3 bucket
resource "aws_s3_bucket" "aws-admin-vault" {
  bucket = "aws-admin-vault"

  tags = {
    Name        = "aws-admin-vault"
    Environment = "Dev"
  }
  
}

resource "aws_dynamodb_table" "aws-admin-vault" {
  name         = "aws-admin-vault" 
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

##############################################################################

# Resource: ACM Certificate
resource "aws_acm_certificate" "acm_cert" {
  domain_name       = "kloudevsecops.com"
  validation_method = "DNS"
  subject_alternative_names = [
    "*.kloudevsecops.com"
  ]

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Fetch the Route 53 Hosted Zone ID
data "aws_route53_zone" "acm_cert" {
  name = "kloudevsecops.com"
}

# Create Route 53 DNS records for validation, excluding kloudevsecops.com
resource "aws_route53_record" "acm_cert" {
  depends_on = [aws_acm_certificate.acm_cert]
  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    } if dvo.domain_name != "kloudevsecops.com" # Put if condition for name  don't want  record set OR Remove the if condition if you want to create a record set for ALL SANs
  }

  zone_id = data.aws_route53_zone.acm_cert.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Validate the ACM certificate
resource "aws_acm_certificate_validation" "acm_cert" {
  depends_on = [aws_route53_record.acm_cert]
  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_cert : record.fqdn]
}


# Outputs
output "acm_certificate_id" {
  value = aws_acm_certificate.acm_cert.id
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.acm_cert.arn
}

output "acm_certificate_status" {
  value = aws_acm_certificate.acm_cert.status
}

# Output the Hosted Zone ID
output "zone_id" {
  value = data.aws_route53_zone.acm_cert.zone_id
}














