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

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-1"
  }
}
