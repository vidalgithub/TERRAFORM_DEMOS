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
