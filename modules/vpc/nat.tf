# Resource: aws_nat_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway

resource "aws_nat_gateway" "gw" {
  depends_on = [
    aws_vpc.kemgou,
    aws_subnet.public,
    aws_eip.nat
  ]

  count = length(local.azs)

  # The Allocation ID of the Elastic IP address for the gateway.
  allocation_id = aws_eip.nat[count.index].id

  # The Subnet ID of the subnet in which to place the gateway.
  subnet_id = aws_subnet.public[count.index * var.public_subnet_count].id

  # A map of tags to assign to the resource.
  tags = {
    Name = "${var.vpc_name}-nat-${count.index + 1}"
  }
}

