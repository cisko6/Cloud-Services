
provider "aws" {
  region = "eu-central-1"
  access_key = "AKIAZGPH7PNHHHCHZITL"
  secret_key = "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"
}

# INSTANCE IN PUBLIC SUBNET CONNECTING TO INTERNET
# 1) VPC
# 2) Internet Gateway
# 3) SUBNET
# 4) ROUTE TABLE
# 5) ROUTE TABLE ASSOCIATION
# 6) SECURITY GROUP
# 7) NETWORK INTERFACE
# 8) ELASTIC IP
# 9) INSTANCE

variable "subnet_IP" {
  description = "cidr block for subnet"
  # default = "10.0.1.0/24" # default value
  # type = bool
}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-igw"
  }
}

resource "aws_subnet" "test-subnet" {
  vpc_id     = aws_vpc.test-vpc.id
  cidr_block = var.subnet_IP[0].cidr_block
  availability_zone = "eu-central-1a"

  tags = {
    Name = var.subnet_IP[0].Name
  }
}

###################################################
resource "aws_route_table" "test-route-table" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }

  tags = {
    Name = "test-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.test-subnet.id
  route_table_id = aws_route_table.test-route-table.id
}
###################################################

resource "aws_security_group" "allow-web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_test-web"
  }
}

#####################################################
resource "aws_network_interface" "net-int" {
  subnet_id       = aws_subnet.test-subnet.id
  private_ips     = [ "10.0.1.50" ]
  security_groups = [ aws_security_group.allow-web.id ]
  #depends_on = [ aws_instance.ubuntu ]
}

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.net-int.id
  associate_with_private_ip = "10.0.1.50"
  #depends_on = [ aws_internet_gateway.test-igw ]
  depends_on = [ aws_instance.ubuntu ]
}
#####################################################

resource "aws_instance" "ubuntu" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name = "my_test_key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.net-int.id
  }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y &&
                sudo apt install -y nginx
                EOF

  tags = {
    Name = "ubuntu_test-test"
  }
}

output "private-ubuntu-IP-address" {
  value = aws_instance.ubuntu.private_ip
}
