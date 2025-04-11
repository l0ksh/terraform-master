# Provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.1"
    }
  }
}

resource "random_string" "random_name" {
  length  = 8
  special = false
  upper   = false
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create EC2 Instance for Web Server
resource "aws_instance" "caribou_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.default.id
  security_groups        = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  # Configure the root EBS volume
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }
  
  tags = {
    Name = "caribou-server-${random_string.random_name.id}"
  }
  
  user_data     = file("/mnt/share/users/lokkumar/terraform_master/user_data.yaml")
}

# Output public IP address of the EC2 instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.caribou_server.public_ip
}

# Local file resource to store the public IP address
resource "local_file" "instance_ip_file" {
  filename = "${path.module}/instance_ip-${random_string.random_name.id}.txt"  
  content  = aws_instance.caribou_server.public_ip         
}

