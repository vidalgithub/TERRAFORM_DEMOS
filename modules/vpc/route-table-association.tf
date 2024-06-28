# Resource: aws_route_table_association
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association


resource "aws_route_table_association" "public-subnet-association" {
  count = length(local.azs) * var.public_subnet_count
  # The subnet ID to create an association.
  subnet_id = aws_subnet.public[count.index].id

  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------

resource "aws_route_table_association" "eks-private-subnet-association" {
  count = length(local.azs) * var.eks_private_subnet_count
  # The subnet ID to create an association.
  subnet_id = aws_subnet.eks_private[count.index].id

  # The ID of the routing table to associate with.
  route_table_id = aws_route_table.eks-private-route[substr(count.index / (var.eks_private_subnet_count), 0, 1)].id
}
# availability_zone = element(local.azs, substr(count.index / (length(local.eks_private_subnets)), 0, 1))

# --------------------------------------------------------------------------------

resource "aws_route_table_association" "db-private-subnet-association" {
  count = length(local.azs) * var.db_private_subnet_count
  # The subnet ID to create an association.
  subnet_id = aws_subnet.db-private[count.index].id

  # The ID of the routing table to associate with.
  /* route_table_id = aws_route_table.db-private-route[count.index].id */
  route_table_id = aws_route_table.db-private-route[substr(count.index / (var.db_private_subnet_count), 0, 1)].id
}

