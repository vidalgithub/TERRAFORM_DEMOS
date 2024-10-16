eks-ng-blue_version  = "1.30"
eks-ng-green_version = "1.30"
node_min             = "1"
desired_node         = "1"
node_max             = "6"

blue_node_color  = "blue"
green_node_color = "green"

blue  = true
green = false

ec2_ssh_key               = "eks-terraform-key"
deployment_nodegroup      = "blue_green"
capacity_type             = "ON_DEMAND"
ami_type                  = "AL2_x86_64"
instance_types            = "t3.medium"
disk_size                 = "40"
shared_owned              = "shared"
enable_cluster_autoscaler = "true"
