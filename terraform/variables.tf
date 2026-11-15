variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for us-east-1"
  type        = string
  default     = "ami-05221e3867c5db247"  # Ubuntu 22.04 LTS - N. Virginia (us-east-1) latest
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "dockerhub_username" {
  description = "Your DockerHub username"
  type        = string
  default     = "baigmazhar"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "mazharhb"
}
