resource "aws_instance" "this" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  user_data = file("../Scripts/nginx.sh")
  tags = {
    Name     = "ec2-trabalho-wr"
    Trabalho = "DevOps"
  }

  connection {
    host = self.private_ip
  }

#   # Configura o volume (mount)
#   provisioner "remote-exec" {
#     inline = [
#       "sudo mkfs.ext4 ${aws_volume_attachment.attached.device}",
#       "sudo mkdir /usr/share/nginx/html",
#       "sudo mount ${aws_volume_attachment.attached.device} /usr/share/nginx/html",
#       "sudo df -h /usr/share/nginx/html",
#     ]
#   }

  # Copia o arquivo nginx.sh para a instancia EC2
  provisioner "file" {
    source      = "nginx.sh"
    destination = "/tmp/nginx.sh"
  }

  # Copia o conteudo do site para o volume EBS
  provisioner "file" {
    source      = "/site"
    destination = "/usr/share/nginx/html"
  }

  # Executa o arquivo nginx.sh
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh"
    ]
  }
}
