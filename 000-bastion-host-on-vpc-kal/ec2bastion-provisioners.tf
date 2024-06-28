# Create a Null Resource and Provisioners
resource "null_resource" "copy_ec2_keys" {
  depends_on = [module.ec2_public]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type     = "ssh"
    host     = aws_eip.bastion_eip.public_ip    
    user     = "ec2-user"
    password = ""
    private_key = file("~/eks-terraform-key.pem") #file("private-key/eks-terraform-key.pem")
  }  

## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "private-key/eks-terraform-key.pem"
    destination = "/tmp/eks-terraform-key.pem"
  }
## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/eks-terraform-key.pem"
    ]
  }
## Local Exec Provisioner:  local-exec provisioner (Creation-Time Provisioner - Triggered during Create Resource)
#   provisioner "local-exec" {
#     command = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
#     working_dir = "${path.module}/local-exec-output-files/"
#     #on_failure = continue
#   }


# Access ${module.ec2_public.public_ip} and "module.ec2_public.public_ip"
# Use the heredoc syntax for multiple lines of commands
provisioner "local-exec" {
  command = <<-EOT
    echo "VPC created on $(date) and VPC ID: ${data.terraform_remote_state.eks.outputs.vpc_id}" >> creation-time-vpc-id.txt &&
    echo "EC2 instance IP address: ${module.ec2_public.public_ip}" >> creation-time-ec2-IP.txt &&
    echo "EC2 instance IP address: ${module.ec2_public.public_ip}" >> creation-time-ec2-IP-test.txt
  EOT
  working_dir = "${path.module}/local-exec-output-files/"
  #on_failure = continue
}

}