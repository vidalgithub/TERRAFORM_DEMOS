output "azs" {
  description = "azs names"
  value       = local.azs
}

output "public_subnets" {
  description = "public_cidr"
  value       = local.public_subnets
}

output "eks_private_subnets" {
  description = "eks_private_cidr"
  value       = local.eks_private_subnets
}

output "db_private_subnets" {
  description = "db_private_subnets_cidr"
  value       = local.db_private_subnets
}

/* output "eks_route" {
    description = "route-tables"
    value = aws_route_table.eks-private-route
} */
