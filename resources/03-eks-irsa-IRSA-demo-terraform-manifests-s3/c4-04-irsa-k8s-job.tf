# Resource: Kubernetes Job
resource "kubernetes_job_v1" "irsa_demo" {
  metadata {
    name = "irsa-demo"
  }
  spec {
    template {
      metadata {
        labels = {
          app = "irsa-demo"
        }
      }
      spec {
        service_account_name = kubernetes_service_account_v1.irsa_demo_sa.metadata.0.name 
        container {
          name    = "irsa-demo"
          image   = "amazon/aws-cli:latest"
          args = ["s3", "ls"]
          # args = ["ec2", "describe-instances", "--region", "${var.aws_region}"] # Should fail as we don't have access to EC2 Describe Instances for IAM Role
          # args = [
          #   "s3", "ls",
          #   "ec2", "describe-instances", "--region", "${var.aws_region}"
          #   ]
          # command = ["aws s3 ls"; "aws ec2 describe-instances --region ${var.aws_region}"]
          # command = ["/bin/sh"]
          # args = [
          #   "-c",
          #   <<EOF
          #     aws s3 ls
          #     aws ec2 describe-instances --region ${var.aws_region}
          #   EOF
          # ]
        }
        restart_policy = "Never"
      }
    }
  }
}