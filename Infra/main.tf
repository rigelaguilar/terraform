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
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  user_data = file("nginx.sh")
  tags = {
    Name     = "ec2-trabalho-wr"
    Trabalho = "DevOps"
  }

  connection {
    host = self.private_ip
  }

  # Copia o arquivo nginx.sh para a instancia EC2
  provisioner "file" {
    source      = "nginx.sh"
    destination = "/tmp/nginx.sh"
  }

  # Copia o conteudo do site para o volume EBS
  provisioner "file" {
    source      = "/site"
    destination = "/dev/sdh"
  }

  # Executa o arquivo nginx.sh
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh"
    ]
  }
}

# 1 EFS
resource "aws_efs_file_system" "this" {
  creation_token = "efs-token-site-trabalho-wr"
  tags = {
    Name     = "efs-trabalho-wr"
    Trabalho = "DevOps"
  }
}

data "aws_availability_zones" "available_ebs" {
  state = "available"
}

# 1 EBS Volume (1 GB)
resource "aws_ebs_volume" "this" {
  availability_zone = data.aws_availability_zones.available_ebs.names[0]
  size = 1
  tags = {
    Name     = "ebs-trabalho-wr"
    Trabalho = "DevOps"
  }
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = aws_instance.this.id
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
