# Resource: aws_internet_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

resource "aws_internet_gateway" "main" {
  depends_on = [
    aws_vpc.kemgou
  ]

  # The VPC ID to create in.
  vpc_id = aws_vpc.kemgou.id

  # A map of tags to assign to the resource.
  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}
