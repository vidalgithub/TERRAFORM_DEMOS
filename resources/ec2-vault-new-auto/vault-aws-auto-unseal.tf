provider "aws" {
  region = "us-east-1" 
}
resource "aws_security_group" "vault_inbound" {
  name        = "vault_inbound"
  description = "Allow inbound traffic to specific ports and outbound to all destinations"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
# provisdion and EC2 instance
resource "aws_instance" "vault-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name      = "terraform-key"
  vpc_security_group_ids = [aws_security_group.vault_inbound.id]

  user_data = <<-EOF
  #!/bin/bash
  # Update and upgrade system
  sudo apt-get update
  sudo apt-get upgrade -y
  # Install Vault
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install vault -y

  # Verify installation
  vault --version

  # Create configuration directory and file
  sudo mkdir /etc/vault.d
  cat <<EOF1 | sudo tee /etc/vault.d/vault.hcl

  seal "awskms" {
       region = "us-east-1"
       kms_key_id = "arn:aws:kms:us-east-1:262485716661:key/mrk-8b3256c180444655aa771bf462e38650"
  }

  storage "file" {
    path = "/opt/vault/data"
  }

  listener "tcp" {
    address     = "0.0.0.0:8200"
    tls_disable = 1
  }

  log_level = "INFO"
  disable_mlock = true
  ui = true
  EOF1

  # Create storage directory
  sudo mkdir -p /opt/vault/data
  sudo chown -R vault:vault /opt/vault

  # Create Vault service file
  cat <<EOF2 | sudo tee /etc/systemd/system/vault.service
  [Unit]
  Description="HashiCorp Vault - A tool for managing secrets"
  Documentation=https://www.vaultproject.io/docs/
  Requires=network-online.target
  After=network-online.target
  ConditionFileNotEmpty=/etc/vault.d/vault.hcl

  [Service]
  User=vault
  Group=vault
  ProtectSystem=full
  ProtectHome=read-only
  PrivateTmp=yes
  ProtectControlGroups=yes
  ProtectKernelModules=yes
  ProtectKernelTunables=yes
  RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
  SystemCallArchitectures=native
  MemoryDenyWriteExecute=yes
  NoNewPrivileges=yes
  EnvironmentFile=/etc/vault.d/vault.env 
  ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
  ExecReload=/bin/kill --signal HUP \$MAINPID
  KillMode=process
  KillSignal=SIGINT
  Restart=on-failure
  RestartSec=5
  TimeoutStopSec=30
  StartLimitInterval=60
  LimitNOFILE=65536

  [Install]
  WantedBy=multi-user.target
  EOF2

  cat <<EOF3 | sudo tee /etc/vault.d/vault.env
  AWS_ACCESS_KEY_ID=""
  AWS_SECRET_ACCESS_KEY=""
  AWS_REGION="us-east-1"
  EOF3

  # Reload systemd
  sudo systemctl daemon-reload

  # Start Vault service
  sudo systemctl start vault

  # Enable Vault service
  sudo systemctl enable vault
  echo "Vault installation and configuration completed. Please proceed with Step 6 and Step 7 manually."
  EOF
  tags = {
    Name = "Vault-Server-Terraform"
  }
}
output "public_ip" {
  value = aws_instance.vault-server.public_ip
}
