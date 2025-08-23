provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Create a new key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key
}

# RDS configuration
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "postgres"
  skip_final_snapshot  = true
  publicly_accessible  = true

  tags = {
    Name = "Postgres RDS"
  }
}

# Security group for RDS and EC2
resource "aws_security_group" "rds_sg" {
  name = "allow_postgres"

  # Allow inbound PostgreSQL traffic
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Modify this for stricter security
  }

  # Allow inbound SSH traffic (port 22) from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP, e.g., "203.0.113.0/32"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 instance using the key pair
resource "aws_instance" "ec2" {
  ami           = "ami-0e86e20dae9224db8"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key_pair.key_name  # Use the key pair created

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "Postgres EC2"
  }
}

# Outputs
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}
