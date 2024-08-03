provider "aws" {
  region = "us-east-1" 
}

resource "aws_security_group" "jenkins-docker" {
  name        = "jenkins-docker"
  description = "Allow inbound traffic to specific ports and outbound to all destinations"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
######## PROVISION INFRASTRUCTURE  #################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
# provision and EC2 instance
resource "aws_instance" "jenkins-docker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  associate_public_ip_address = true
  key_name      = "terraform-key"
  vpc_security_group_ids = [aws_security_group.jenkins-docker.id]

  user_data = <<-EOF
#!/bin/bash

# This script will install Java and Jenkins
echo "Checking the operating system"
OS=$(cat /etc/os-release | grep PRETTY_NAME | awk -F= '{print $2}' | awk -F '"' '{print $2}' | awk '{print $1}')

echo 'Checking if Jenkins is installed'
ls /var/lib | grep jenkins
if [[ $? -eq 0 ]]; then 
    echo "Jenkins is installed"
    exit 1
else
    sudo apt update
    sudo apt install ca-certificates -y
    sudo apt update
    sudo apt install fontconfig openjdk-17-jre -y
    java -version
    sudo ufw allow 8080/tcp 2> /dev/null
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins -y
    sudo systemctl start jenkins 
    sudo systemctl enable jenkins
    touch /tmp/password
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /tmp/password
    echo "Jenkins password is: $(cat /tmp/password)"
fi

# Uninstall any previous Docker engine
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Install Docker engine using apt repository
# Set up Docker's apt repository.
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install curl -y
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker packages.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Verify that the Docker Engine installation is successful by running the hello-world image.
sudo docker run hello-world
if [[ $? -eq 0 ]]; then 
    echo "Succesfully installed Docker"
    exit 0
else
    echo "Fail to install Docker"
fi
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins


  EOF
  tags = {
    Name = "TF-Jenkins-Docker"
  }
}
output "public_ip" {
  value = aws_instance.jenkins-docker.public_ip
}
