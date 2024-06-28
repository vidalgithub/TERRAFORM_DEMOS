
# Resource: aws_route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table


resource "aws_route_table" "public" {
  depends_on = [
    aws_vpc.kemgou,
    aws_subnet.public,
    aws_subnet.eks_private,
    aws_subnet.db-private,
    aws_eip.nat
  ]
  # The VPC ID.
  vpc_id = aws_vpc.kemgou.id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC internet gateway or a virtual private gateway.
    gateway_id = aws_internet_gateway.main.id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "public"
  }
}

#-----------------------------------------------------------------

resource "aws_route_table" "eks-private-route" {

  count = length(local.azs)
  # The VPC ID.
  vpc_id = aws_vpc.kemgou.id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC NAT gateway.

    nat_gateway_id = aws_nat_gateway.gw[count.index].id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "eks-private-route-${count.index + 1}"
  }
}


#-----------------------------------------------------------------

resource "aws_route_table" "db-private-route" {

  count = length(local.azs)
  # The VPC ID.
  vpc_id = aws_vpc.kemgou.id

  route {
    # The CIDR block of the route.
    cidr_block = "0.0.0.0/0"

    # Identifier of a VPC NAT gateway.
    nat_gateway_id = aws_nat_gateway.gw[count.index].id
  }

  # A map of tags to assign to the resource.
  tags = {
    Name = "db-private-route-${count.index + 1}"
  }
}

