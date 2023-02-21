terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    
    }
  }
 
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "snipe_security" {
    name = "snipe_security"
    description = "Allow inbound traffic from the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description      = "TLS from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }


}

resource "aws_db_instance" "mysql" {
    engine = "mysql"
    instance_class = "db.t2.micro"
    allocated_storage = 10
    max_allocated_storage = 100
    db_name = var.mysql_dbname
    username = var.username
    password = var.mysql_password
    skip_final_snapshot = true

     vpc_security_group_ids = [
      aws_security_group.snipe_security.id
    ]

}

resource "random_uuid" "uuid" {}

resource "aws_s3_bucket" "snipe_it_bucket" {
  bucket = "snipe-it-bucket-${random_uuid.uuid.result}"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "snipe_it_policy" {
  bucket = aws_s3_bucket.snipe_it_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.snipe_it_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_instance" "snipe-instance" {
    ami = "ami-0dfcb1ef8550277af"
    instance_type = "t2.micro"
    key_name = "ec2"

    vpc_security_group_ids = [ 
        aws_security_group.snipe_security.id
    ]

    tags = {
      Name  = "snipe-instance"
    }

    connection {
      type        = "tcp"
      host        = aws_db_instance.mysql.endpoint
      port        = 3306
      timeout     = "2m"
      retries     = 0
    }
    
    user_data = <<-EOF
      #!/bin/bash
      sudo yum update -y
      sudo amazon-linux-extras install docker -y
      sudo service docker start
      sudo usermod -a -G docker ec2-user

      sudo docker run -d \
        -p 80:80 \
        -p 443:443 \
        --name snipeit_container \
        -e "APP_ENV=production" \
        -e "APP_KEY=base64:D5oGA+zhFSVA3VwuoZoQ21RAcwBtJv/RGiqOcZ7BUvI=" \
        -e "APP_URL=http://localhost:80" \
        -e "MYSQL_HOST=${aws_db_instance.mysql.endpoint}" \
        -e "MYSQL_DATABASE=${var.mysql_dbname}" \
        -e "MYSQL_USER=${var.username}" \
        -e "MYSQL_PASSWORD=${var.mysql_password}" \
        -e "APP_DEBUG=false" \
        --restart unless-stopped \
        snipe/snipe-it
      EOF

    depends_on = [
      aws_db_instance.mysql,
      aws_security_group.snipe_security
    ]
  
}

output "public_ip" {
    value = aws_instance.snipe-instance.public_ip
}