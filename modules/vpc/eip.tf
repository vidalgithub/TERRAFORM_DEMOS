# Resource: aws_eip
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.main]
  count      = length(local.azs)
  vpc        = true

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
  }
}



