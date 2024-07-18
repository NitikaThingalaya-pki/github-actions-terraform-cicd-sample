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

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id  # Ensure the subnet does not auto-assign public IPs

  network_interface {
    device_index                  = 0
    network_interface_id          = aws_network_interface.example.id
    associate_public_ip_address   = false
  }

  tags = {
    Name = var.name
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update
              sudo yum -y install httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_network_interface" "example" {
  subnet_id = var.subnet_id

  tags = {
    Name = "example-nic"
  }
}
