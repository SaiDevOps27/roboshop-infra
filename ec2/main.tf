data "aws_ami" "ami" {
  most_recent = "true"
  name_regex = "Centos-8-DevOps-Practice"
  owners     = ["973714476881"]
}

resource "aws_instance" "ec2" {
  ami            = data.aws_ami.ami.image_id
  instance_type  = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = var.component
  }
}

resource "null_resource" "provisioner" {

  provisioner "remote-exec" {
    connection {
      host = aws_instance.ec2.public_ip
      user = "centos"
      password = "DevOps321"
    }

    inline = [
      "git clone https://github.com/SaiDevOps27/roboshop-shell",
      "cd roboshop-shell",
      "sudo bash ${var.component}.sh ${var.password}"
    ]
  }
}



resource "aws_security_group" "sg" {
  name = "${var.component}-${var.env}-sg"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "ALL"
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}
resource "aws_route53_record" "record" {
  zone_id = "Z10476648NCZMQR6CZBG"
  name    = "${var.component}-dev.devopsb.cloud"
  type    = "A"
  ttl     = 30
  records = [aws_instance.ec2.private_ip]
}
variable "instance_type" {}
variable "component" {}
variable "env" {
  default = "dev"
}
variable "password" {}

