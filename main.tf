provider "aws" {
  region     = "ap-northeast-2"
}

resource "aws_instance" "terraform-ec2-server" {
  ami           = "ami-0ea5eb4b05645aa8a"
  instance_type = "t2.micro"
  tags = {
    Name = "terraform-ec2-server"
  }
}

resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    "Name" = "terraform-vpc"
  }
}

resource "aws_subnet" "terraform-subnet-public-01" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    "Name" = "terraform-subnet-public-01"
  }
  
}

# resource "<provider>_<resource>" "name" {
#   config options...
#   key = "value"
#   key2 = "another value"
# }
