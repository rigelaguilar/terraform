# 1 VPC
resource "aws_vpc" "this" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name     = "vpc-trabalho-wr"
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
  route_table_id         = aws_vpc.this.main_route_table_id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block    = "0.0.0.0/0"
}

data "aws_availability_zones" "available_vpc" {
  state = "available"
}

# 1 Subnet
resource "aws_subnet" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available_vpc.names[0]
  tags = {
    Name     = "subnet-trabalho-wr"
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
