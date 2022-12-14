terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"


  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route" "route" {
  route_table_id = aws_route_table.public-route-table.id
  destination_cidr_block     = "0.0.0.0/0"
  gateway_id     = aws_internet_gateway.public.id
  depends_on     = [aws_route_table.public-route-table]
}

resource "aws_instance" "load-balancer" {
  ami = "ami-051dfed8f67f095f5"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  subnet_id = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash
  echo "Hello World" > index.html
  nohup busybox httpd -f -p 80 &
  EOF
  tags = {
    Name = "load-balancer"
  }
}

resource "aws_security_group" "instance" {
  name = "instance"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
