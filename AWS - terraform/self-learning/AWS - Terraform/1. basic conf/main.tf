provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "fist-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.fist-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}

# resource "aws_instance" "my-first-server" {
#   ami           = "ami-053b0d53c279acc90"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "ubuntu"
#   }
# }
