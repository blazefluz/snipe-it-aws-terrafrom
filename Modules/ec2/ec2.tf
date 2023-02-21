resource "aws_key_pair" "ssh-key-pair" {
  key_name   = var.ec2_ssh_key_name
  public_key = var.ec2_ssh_public_key
}

data "aws_ami" "bastion-ami" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "bastion-intance" {
  ami           = data.aws_ami.bastion-ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh-key-pair.key_name

  tags = var.tags

  vpc_security_group_ids = [
    var.security_group_ids.http,
    var.security_group_ids.ssh,
    
  ]

  subnet_id = var.subnet_ids.public

  connection {
    type = "ssh"
    user = "ununtu"
    host = self.public_ip
    private_key = file("key")
  }

    tag =var.tags
}

resource "aws_eip" "bastion-eip" {
  instance = aws_instance.bastion-intance.id
  vpc      = true

  tags = var.tags
}

resource "aws_route53_record" "bastion-dns" {
  zone_id = var.route53_zone_id
  name    = "bastion.${var.domain}"
  type    = "CNAME"
  ttl     = "5"
  records = [aws_eip.bastion-eip.public_dns]
}