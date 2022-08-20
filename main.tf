provider "aws" {
  region     = "ap-northeast-2"
}

resource "aws_instance" "my_first_server" {
  ami           = "ami-0ea5eb4b05645aa8a"
  instance_type = "t2.micro"
  tags = {
    Name = "ubuntu"
  }
}

# resource "<provider>_<resource>" "name" {
#   config options...
#   key = "value"
#   key2 = "another value"
# }
