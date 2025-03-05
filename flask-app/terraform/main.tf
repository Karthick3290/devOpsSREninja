resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "network-vpc"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  availability_zone = "us-east-1a"
  cidr_block = "10.1.0.0/24"
}