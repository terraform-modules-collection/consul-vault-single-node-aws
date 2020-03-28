provider "aws" {
  region = "us-east-1"
}
//ami-0affd4508a5d2481b
data "aws_ami" "centos" {
  owners = ["679593333241"]
  filter {
    name = "image-id"
    values = ["ami-0affd4508a5d2481b"]
  }
}

data "template_file" "user-data" {
  template = file("${path.module}/templates/user-data.yaml")
  vars = {
    sshPubKey = var.sshPubKey
    sshUserName = var.sshUserName
  }
}

data "template_cloudinit_config" "user-data" {
  part {
    content = data.template_file.user-data.rendered
    content_type = "text/cloud-config"
  }
}

resource "aws_security_group" "public-security-group" {
  name = "hashicorp-vault-sg"
  description = "Security group for HashiCorp Vault"
  vpc_id = var.vpcID
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "hashicorp-vault-sg"
  }
}

resource "aws_instance" "vault" {
  ami = data.aws_ami.centos.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.public-security-group.id]
  user_data = data.template_cloudinit_config.user-data.rendered
  tags = {
    name = "hashicorp-vault"
  }

}

