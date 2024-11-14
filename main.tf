terraform {
  backend "s3" {
    bucket         = "s306022024"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_iam_role" "existing_role" {
  name = var.aws_role
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile = data.aws_iam_role.existing_role.name
  associate_public_ip_address = "false"

  tags = {
    Name = var.name
  }

  user_data = file("install_agent.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Security group allowing full access to a sensitive port"

  ingress {
    description = "Allow all traffic on port 22 (SSH) from any IP"
    from_port   = 445             # Sensitive port (e.g., SSH or a database port)
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Full access (not recommended in production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
}
