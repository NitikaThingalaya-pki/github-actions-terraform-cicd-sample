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



variable "sensitive_data" {
  description = "Sensitive PII and secrets data"
  type        = string
  default     = jsonencode({
    user = {
      firstName             = "John"
      lastName              = "Doe"
      email                 = "john.doe@example.com"
      phoneNumber           = "+1234567890"
      socialSecurityNumber  = "123-45-6789"
      address               = {
        street  = "123 Main St"
        city    = "Anytown"
        state   = "Anystate"
        zipCode = "12345"
      }
    }
    credentials = {
      apiKey      = "ABCD1234EFGH5678IJKL91011MNOP"
      password    = "s3cr3tP@ssw0rd"
      accessToken = "ya29.A0ARrdaM-pqDl3a9mO1qLjDzV5VzOzL"
      privateKey  = "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASC...END PRIVATE KEY-----"
    }
  })
}


variable "name" {
  description = "Name of EC2 Intance"
}
