terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "4.25.0"
    }
  }
  backend "s3" {
    profile = "trabalho-devops-wr"
    bucket  = "s3-trabalho-wr"
    key     = "state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "trabalho-devops-wr"
}

# 1 EC2
resource "aws_instance" "this" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  count         = 1
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  user_data = file("nginx.sh")
  tags = {
    Name     = "ec2-trabalho-wr"
    Trabalho = "DevOps"
  }
}

# 1 VPC
resource "aws_vpc" "this" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name     = "vpc-trabalho-wr"
    Trabalho = "DevOps"
  }
}

# 1 Subnet
resource "aws_subnet" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name     = "subnet-trabalho-wr"
    Trabalho = "DevOps"
  }
}

# 1 Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name     = "gateway-trabalho-wr"
    Trabalho = "DevOps"
  }
}

# 1 Route
resource "aws_route" "this" {
  route_table_id            = "route-trabalho-wr-table-id"
  destination_cidr_block    = "0.0.0.0/0"
  vpc_peering_connection_id = "pcx-45ff3dc1"
}

# 1 EFS
resource "aws_efs_file_system" "this" {
  creation_token = "efs-token-site-trabalho-wr"
  tags = {
    Name     = "efs-trabalho-wr"
    Trabalho = "DevOps"
  }
}

# 1 EBS Volume (1 GB)
resource "aws_ebs_volume" "this" {
  availability_zone = "us-east-1"
  size = 1
  tags = {
    Name     = "ebs-trabalho-wr"
    Trabalho = "DevOps"
  }
}

# 1 Security Group
resource "aws_security_group" "this" {
  name        = "security_group_trabalho_wr"
  description = "Security Group para acesso SSH e HTTP do Trabalho de Terraform"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "security-group-trabalho-wr"
    Trabalho = "DevOps"
  }
}

# nginx installation
# storing the nginx.sh file in the EC2 instnace
provisioner "file" {
  source      = "nginx.sh"
  destination = "/tmp/nginx.sh"
}
# Executa o arquivo nginx.sh
provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/nginx.sh",
    "sudo /tmp/nginx.sh"
  ]
}

# resource "aws_efs_mount_target" "this" {
#   file_system_id  = aws_efs_file_system.this.id
#   subnet_id       = aws_instance.this.subnet_id
#   security_groups = [aws_security_group.this.id]
# }
# resource "null_resource" "configure_nfs" {
#   depends_on = [aws_efs_mount_target.this]
#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = tls_private_key.my_key.private_key_pem
#     host        = aws_instance.web.public_ip
#   }
# }