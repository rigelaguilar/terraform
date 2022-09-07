data "aws_availability_zones" "available_ebs" {
  state = "available"
}

resource "aws_ebs_volume" "this" {
  availability_zone = data.aws_availability_zones.available_ebs.names[0]
  size = 1
  tags = {
    Name     = "ebs-trabalho-wr"
    Trabalho = "DevOps"
  }
}

resource "aws_volume_attachment" "this" {
  device_name = "volume-trabalho-wr"
  volume_id   = aws_ebs_volume.this.id
  instance_id = aws_instance.this.id
}

resource "aws_efs_file_system" "this" {
  creation_token = "efs-token-site-trabalho-wr"
  tags = {
    Name     = "efs-trabalho-wr"
    Trabalho = "DevOps"
  }
}