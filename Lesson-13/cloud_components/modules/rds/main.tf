data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "ai-lab-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
  description = "Subnet group for RDS"
}

resource "aws_security_group" "db" {
  name   = "ai-lab-db-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
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

resource "aws_db_instance" "this" {
  identifier           = "ai-lab-db"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot  = true
  publicly_accessible  = true
}