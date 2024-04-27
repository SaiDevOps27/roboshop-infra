data "aws_ssm_parameter" "ssh_pass" {
  name = "${var.env}.ssh.pass"
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex = "Centos-8-Devops-Practice"
  owners = ["973714476881"]
}



