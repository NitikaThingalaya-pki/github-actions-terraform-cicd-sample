variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "EC2 Subnet ID"
  default     = "subnet-4939313f"
}

variable "key_name" {
  description = "Name of the existing EC2 key pair"
  default = "CICD_Ubuntu_Key"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for remote state"
  default = "tfdemo16112023"
}

variable "name" {
  description = "Name of EC2 Intance"
}
