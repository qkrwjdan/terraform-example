# 1. create vpc 
# 2. create Internet gateway
# 3. create custom route table 
# 4. create a subnet
# 5. associate subnet with route table 
# 6. create security group to allow port 22, 80, 443
# 7. create a network interface with an ip in the subnet that was created in step 4
# 8. assign an elastic ip to the network interface created in step 7
# 9. create ubuntu server and install/enable apache2

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "terraform-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    "Name" = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    "Name" = "terraform-igw"
  }
}

resource "aws_route_table" "terraform-rt" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.terraform-igw.id
  }

  tags = {
    "Name" = "terraform-igw"
  }
}

resource "aws_subnet" "terraform-subnet-public-01" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    "Name" = "terraform-subnet-public-01"
  }
}

resource "aws_route_table_association" "subnet-rt-association" {
  subnet_id      = aws_subnet.terraform-subnet-public-01.id
  route_table_id = aws_route_table.terraform-rt.id
}

resource "aws_security_group" "terraform-sg-web-server" {
  name        = "terraform-sg-web-server"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "terraform-sg-web-server"
  }
}

resource "aws_network_interface" "terraform-nic-web-server" {
  subnet_id       = aws_subnet.terraform-subnet-public-01.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.terraform-sg-web-server.id]
}

resource "aws_eip" "terraform-eip-web-server" {
  vpc                       = true
  network_interface         = aws_network_interface.terraform-nic-web-server.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.terraform-igw]
}

resource "aws_instance" "terraform-ec2-server" {
  ami               = "ami-0ea5eb4b05645aa8a"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-2a"
  key_name          = "terraform-key-pair"

  network_interface {
    network_interface_id = aws_network_interface.terraform-nic-web-server.id
    device_index         = 0
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                EOF
  tags = {
    Name = "terraform-ec2-server"
  }
}

# resource "<provider>_<resource>" "name" {
#   config options...
#   key = "value"
#   key2 = "another value"
# }
