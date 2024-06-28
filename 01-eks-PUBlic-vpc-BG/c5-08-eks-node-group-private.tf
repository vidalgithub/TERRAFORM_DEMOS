# # Create AWS EKS Node Group - Private
# resource "aws_eks_node_group" "eks_ng_private_blue" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name

#   node_group_name = "${local.name}-eks-ng-private_blue"
#   node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids      = module.vpc.private_subnets
#   version = var.eks-ng-blue_version  #(Optional: Defaults to EKS Cluster Kubernetes version)    

#   capacity_type = var.capacity_type
#   ami_type      = var.ami_type
#   instance_types = [var.instance_types]
#   disk_size      = var.disk_size

#   remote_access {
#     ec2_ssh_key = var.ec2_ssh_key
#   }

#   scaling_config {
#     desired_size = var.blue_node_color == "blue" && var.blue ? var.desired_node : 0
#     min_size     = var.blue_node_color == "blue" && var.blue ? var.node_min : 0
#     max_size     = var.blue_node_color == "blue" && var.blue ? var.node_max : var.node_max
#   }

#   labels = {
#     deployment_nodegroup = var.deployment_nodegroup
#   }

#   # Desired max percentage of unavailable worker nodes during node group update.
#   update_config {
#     max_unavailable = 1    
#     #max_unavailable_percentage = 50    # ANY ONE TO USE
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
#     kubernetes_config_map_v1.aws_auth
#   ]  

#   tags = {
#     Name = "Private-Node-Group"
#     "k8s.io/cluster-autoscaler/${local.control_plane_name}" = "${var.shared_owned}"
#     "k8s.io/cluster-autoscaler/enabled"                     = "${var.enable_cluster_autoscaler}"
#   }
# }



# # Create AWS EKS Node Group - Private
# resource "aws_eks_node_group" "eks_ng_private_green" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name

#   node_group_name = "${local.name}-eks-ng-private_green"
#   node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
#   subnet_ids      = module.vpc.private_subnets
#   version = var.eks-ng-green_version  #(Optional: Defaults to EKS Cluster Kubernetes version)    

#   capacity_type = var.capacity_type
#   ami_type      = var.ami_type
#   instance_types = [var.instance_types]
#   disk_size      = var.disk_size

#   remote_access {
#     ec2_ssh_key = var.ec2_ssh_key
#   }

#   scaling_config {
#     desired_size = var.green_node_color == "green" && var.green ? var.desired_node : 0
#     min_size     = var.green_node_color == "green" && var.green ? var.node_min : 0
#     max_size     = var.green_node_color == "green" && var.green ? var.node_max : var.node_max
#   }

#   labels = {
#     deployment_nodegroup = var.deployment_nodegroup
#   }

#   # Desired max percentage of unavailable worker nodes during node group update.
#   update_config {
#     max_unavailable = 1    
#     #max_unavailable_percentage = 50    # ANY ONE TO USE
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
#     aws_iam_role_policy_attachment.eks-Autoscaling-Full-Access,
#   ]  

#   tags = {
#     Name = "Private-Node-Group"
#     "k8s.io/cluster-autoscaler/${local.control_plane_name}" = "${var.shared_owned}"
#     "k8s.io/cluster-autoscaler/enabled"                     = "${var.enable_cluster_autoscaler}"
#   }
# }


# # EKS Node Group Outputs - Private - Blue
# output "node_group_private_blue_id" {
#   description = "Node Group 1 ID"
#   value       = aws_eks_node_group.eks_ng_private_blue.id
# }

# output "node_group_private_blue_arn" {
#   description = "Private Node Group ARN"
#   value       = aws_eks_node_group.eks_ng_private_blue.arn
# }

# output "node_group_private_blue_status" {
#   description = "Private Node Group status"
#   value       = aws_eks_node_group.eks_ng_private_blue.status 
# }

# output "node_group_private_blue_version" {
#   description = "Private Node Group Kubernetes Version"
#   value       = aws_eks_node_group.eks_ng_private_blue.version
# }


# # EKS Node Group Outputs - Private - Green
# output "node_group_private_green_id" {
#   description = "Node Group 1 ID"
#   value       = aws_eks_node_group.eks_ng_private_green.id
# }

# output "node_group_private_green_arn" {
#   description = "Private Node Group ARN"
#   value       = aws_eks_node_group.eks_ng_private_green.arn
# }

# output "node_group_private_green_status" {
#   description = "Private Node Group status"
#   value       = aws_eks_node_group.eks_ng_private_green.status 
# }

# output "node_group_private_green_version" {
#   description = "Private Node Group Kubernetes Version"
#   value       = aws_eks_node_group.eks_ng_private_green.version
# }

