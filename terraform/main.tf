# AMI - resolved dynamically instead of hardcoded

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  common_tags = {
    Project     = var.project_name
    ManagedBy   = "terraform"
    Environment = "practice"
  }
}


# Security Groups


resource "aws_security_group" "node1_sg" {
  name        = "${var.project_name}-node1-sg"
  description = "Node 1 (end user): HTTP public, SSH only from Node 2 or admin"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Node 2 (Jenkins deploy step)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.node2_sg.id]
  }

  ingress {
    description = "SSH from admin workstation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "HTTP - public app access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-node1-sg" })
}

resource "aws_security_group" "node2_sg" {
  name        = "${var.project_name}-node2-sg"
  description = "Node 2 (CI/CD): Jenkins + SonarQube UIs, SSH from admin only"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin workstation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "SonarQube UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "App access - Swiggy container runs on this node"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-node2-sg" })
}

resource "aws_security_group" "node3_sg" {
  name        = "${var.project_name}-node3-sg"
  description = "Node 3 (monitoring): SSH from admin only"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin workstation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-node3-sg" })
}


# EC2 Instances

resource "aws_instance" "node1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_types.node1
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.node1_sg.id]

  metadata_options {
    http_tokens   = "required" # enforces IMDSv2 - blocks a common SSRF/credential-theft vector
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size           = var.root_volume_sizes.node1
    volume_type            = "gp3"
    encrypted              = true
    delete_on_termination  = true
  }

  tags = merge(local.common_tags, { Name = "Node1-EndUser" })
}

resource "aws_instance" "node2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_types.node2
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.node2_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size            = var.root_volume_sizes.node2
    volume_type             = "gp3"
    encrypted                = true
    delete_on_termination    = true
  }

  tags = merge(local.common_tags, { Name = "Node2-CICD" })
}

resource "aws_instance" "node3" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_types.node3
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.node3_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_size            = var.root_volume_sizes.node3
    volume_type             = "gp3"
    encrypted                = true
    delete_on_termination    = true
  }

  tags = merge(local.common_tags, { Name = "Node3-Monitoring" })
}
