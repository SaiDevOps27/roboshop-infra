
resource "aws_instance" "ec2" {
  ami            = data.aws_ami.ami.image_id
  instance_type  = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = var.component
  }
}

resource "null_resource" "provisioner" {
  depends_on = [aws_route53_record.record]
  provisioner "remote-exec" {
    connection {
      host = aws_instance.ec2.public_ip
      user = "centos"
      password = "DevOps321"
    }

    inline = [
      "ansible-pull -i localhost, -U https://github.com/SaiDevOps27/roboshop-ansible.git roboshop.yml -e role_name=${var.component}"
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
resource "aws_iam_policy" "ssm-policy" {
  name        = "${var.env}-${var.component}-ssm"
  path        = "/"
  description = "${var.env}-${var.component}-ssm"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}





