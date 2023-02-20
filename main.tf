provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "snipe-instance" {
    ami = "ami-0dfcb1ef8550277af"
    instance_type = "t2.micro"

    tags = {
      Name  = "snipe-instance"
    }
    user_data = <<-EOF
        #!bin/bash
        sudo yum update -y
        sudo yum install -y docker
        sudo service docker start
        sudo usermod -a -G docker ec2-user
        docker run --rm snipe/snipe-it
        EOF
}

resource "aws_security_group" "snipe_security" {
    name = "snipe_security"
    description = "Allow inbound traffic from the internet"
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

}

resource "aws_s3_bucket" "snipeit-bucket" {
    bucket = ""
}
