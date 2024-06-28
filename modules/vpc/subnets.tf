# create public subnets dynamically using cidrsubnet function for cidr blocks

# Azs
data "aws_availability_zones" "available" {
}

locals {
  vpc_cidr   = var.vpc_cidr
  azs        = slice(data.aws_availability_zones.available.names, 0, var.azs_count)
  eks_netnum = (var.public_subnet_count * length(local.azs)) + 1
  db_netnum  = local.eks_netnum + (var.eks_private_subnet_count * length(local.azs))
  public_subnets = [
    for i in range(var.public_subnet_count * length(local.azs)) :
    cidrsubnet(aws_vpc.kemgou.cidr_block, var.newbits, i + 1) # cidrsubnet(prefix, newbits, netnum)

  ]
  eks_private_subnets = [
    for i in range(var.eks_private_subnet_count * length(local.azs)) :
    cidrsubnet(aws_vpc.kemgou.cidr_block, var.newbits, local.eks_netnum + i)
  ]
  db_private_subnets = [
    for i in range(var.db_private_subnet_count * length(local.azs)) :
    cidrsubnet(aws_vpc.kemgou.cidr_block, var.newbits, local.db_netnum + i)
  ]
}


resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.kemgou
  ]
  count = length(local.azs) * var.public_subnet_count

  vpc_id = aws_vpc.kemgou.id
  /* cidr_block = element(local.public_subnets, count.index)
  availability_zone = element(local.azs, count.index % length(local.azs)) */
  cidr_block        = element(local.public_subnets, (count.index % (length(local.azs) * var.public_subnet_count)))
  availability_zone = element(local.azs, substr((count.index / (var.public_subnet_count)), 0, 1))

  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-subnet-${count.index + 1}"
  }

}

# -------------------------------------------------------------------------------------------------------

resource "aws_subnet" "eks_private" {
  count = length(local.azs) * var.eks_private_subnet_count

  vpc_id = aws_vpc.kemgou.id

  cidr_block        = element(local.eks_private_subnets, (count.index % (length(local.azs) * var.eks_private_subnet_count)))
  availability_zone = element(local.azs, substr((count.index / (var.eks_private_subnet_count)), 0, 1))

  tags = {
    "Name" = "eks-private-subnet-${count.index + 1}"
  }


}

# ---------------------------------------------------------------------------------------------------------

resource "aws_subnet" "db-private" {
  count = length(local.azs) * var.db_private_subnet_count

  vpc_id = aws_vpc.kemgou.id
  /* cidr_block = element(local.db_private_subnets, count.index)
  availability_zone = element(local.azs, count.index % length(local.azs)) */
  cidr_block        = element(local.db_private_subnets, (count.index % (length(local.azs) * var.db_private_subnet_count)))
  availability_zone = element(local.azs, substr((count.index / (var.db_private_subnet_count)), 0, 1))
  tags = {
    "Name" = "db-private-subnet-${count.index + 1}"
  }


}





#==============================================================================================
#===============================================================================================



/* resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.kemgou
  ]

  count = length(local.public_subnets)



  cidr_block = element(local.public_subnets, count.index)

  vpc_id = aws_vpc.kemgou.id

  # The AZ for the subnet.

  # availability_zone = data.aws_availability_zones.available.names[2]  #"us-east-1a"
  
  availability_zone = local.azs[0]

  map_public_ip_on_launch = true
  tags = {
    "Name" = "eks-public-subnet-${count.index + 1}"
  }

  # Add any other configuration for your subnets here
}

# -------------------------------------------------------------------------------------

# create private subnets dynamically for node group using cidrsubnet function for cidr blocks

resource "aws_subnet" "eks_private" {
  depends_on = [
    aws_vpc.kemgou,
    aws_subnet.public
  ]

  count = length(local.eks_private_subnets)

  cidr_block = element(local.eks_private_subnets, count.index)

  vpc_id = aws_vpc.kemgou.id

  # The AZ for the subnet.
  # availability_zone = data.aws_availability_zones.available.names[2]  #"us-east-1a"
  availability_zone = local.azs[0]

  tags = {
    "Name" = "eks-private-subnet-${count.index + 1}"
  }

  # Add any other configuration for your subnets here
}

# ---------------------------------------------------------------------------------------------

# create private subnets dynamically for db using cidrsubnet function for cidr blocks

resource "aws_subnet" "db-private" {
  depends_on = [
    aws_vpc.kemgou,
    aws_subnet.public,
    aws_subnet.eks_private
  ]

  count = length(local.db_private_subnets)

  cidr_block = element(local.db_private_subnets, count.index)

  vpc_id = aws_vpc.kemgou.id

  # The AZ for the subnet.
  # availability_zone = data.aws_availability_zones.available.names[2]  #"us-east-1a"
  availability_zone = local.azs[0]

  tags = {
    "Name" = "db-private-subnet-${count.index + 1}"
  }

  # Add any other configuration for your subnets here
}

 */
