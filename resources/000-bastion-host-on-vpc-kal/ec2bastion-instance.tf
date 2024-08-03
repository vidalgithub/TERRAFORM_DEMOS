# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  source  = "../../modules/bastion-host-vpc/bastion-host-kalyan"
  #version = "~> 3.0"
#   version = "3.3.0"

  name = "${local.name}-BastionHost"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  #monitoring             = true
  subnet_id              = data.terraform_remote_state.eks.outputs.public_subnets[0]  # module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  
  tags = local.common_tags
}
