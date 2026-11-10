variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "VPC to deploy all resources into"
  type        = string
  default     = "vpc-0782b1b3214313531"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair used to SSH into instances"
  type        = string
  default     = "devOps"
}

variable "admin_cidr" {
  description = "Your own IP address (as a /32 CIDR) allowed to SSH into Node 2 and Node 3 directly. Get yours with: curl -s ifconfig.me"
  type        = string
  # No default on purpose - forces you to set this in terraform.tfvars
  # instead of silently deploying with an open SSH port.
}

variable "project_name" {
  description = "Prefix used for tagging every resource"
  type        = string
  default     = "devops-project"
}

variable "instance_types" {
  description = "Instance type per node"
  type = object({
    node1 = string
    node2 = string
    node3 = string
  })
  default = {
    node1 = "t2.micro"
    node2 = "t2.large" # Jenkins + SonarQube + Docker together need the headroom
    node3 = "t2.micro"
  }
}

variable "root_volume_sizes" {
  description = "Root EBS volume size (GiB) per node"
  type = object({
    node1 = number
    node2 = number
    node3 = number
  })
  default = {
    node1 = 30
    node2 = 50 # SonarQube images + Docker layers eat disk fast
    node3 = 25
  }
}
