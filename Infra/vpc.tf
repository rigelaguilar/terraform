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

