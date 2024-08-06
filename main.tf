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
