provider "aws" {
  region = "us-east-1"  # Specify your preferred AWS region
}

# Data source to get the latest Ubuntu 20.04 LTS AMI for x86_64 architecture
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]  # Canonical's AWS Account ID for Ubuntu AMIs
}

# Create an SSH key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your public key
}

# Create an OpenSearch domain
resource "aws_elasticsearch_domain" "my_opensearch_alexk" {
  domain_name           = "my-opensearch-alexk-domain"
  elasticsearch_version = "OpenSearch_1.0"

  cluster_config {
    instance_type  = "t3.small.elasticsearch"  # Use a valid OpenSearch instance type
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10  # Size in GB
  }

  # Enable encryption at rest
  encrypt_at_rest {
    enabled = true
  }

  # Enable node-to-node encryption
  node_to_node_encryption {
    enabled = true
  }

  # Enable Fine-Grained Access Control
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled  = true
    master_user_options {
      master_user_name              = "admin"
      master_user_password          = "StrongPassword123!"
    }
  }
  domain_endpoint_options {
    enforce_https = true
  }

  access_policies = <<POLICIES
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "es:*",
        "Resource": "arn:aws:es:us-east-1:881490130721:domain/my-opensearch-alexk-domain/*",
        "Condition": {
          "IpAddress": {
            "aws:SourceIp": ["${aws_instance.ec2.private_ip}/32"]
          }
        }
      },
{
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-1:749406770300:domain/my-opensearch-alexk-domain/*",
      "Condition": {
        "StringEquals": {
          "es:username": "admin"
        }
      }
    }
    ]
  }
  POLICIES

  tags = {
    Name = "OpenSearch Cluster"
  }
}

# Security group for EC2
resource "aws_security_group" "ec2_sg" {
  name = "allow_http_ssh"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere (for demo purposes)
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance to interact with OpenSearch
resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id  # Use the latest Ubuntu AMI
  instance_type = "t3.micro"
  key_name      = aws_key_pair.my_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "OpenSearch Ubuntu EC2"
  }

  # User data to install curl, AWS CLI, and jq for interacting with OpenSearch
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y awscli curl jq
              EOF
}

# Outputs

# Output the EC2 instance's private IP address
output "ec2_private_ip" {
  value = aws_instance.ec2.private_ip
}

# Output the OpenSearch domain's endpoint
output "opensearch_endpoint" {
  value = aws_elasticsearch_domain.my_opensearch_alexk.endpoint
}

# Output the EC2 instance's public IP for SSH access
output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}
