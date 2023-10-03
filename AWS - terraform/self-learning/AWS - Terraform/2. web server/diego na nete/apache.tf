
# 1. Create vpc
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create a Subnet 
# 5. Associate subnet with Route Table
# 6. Create Security Group to allow port 22,80,443
# 7. Create a network interface with an ip in the subnet
# 8. Assign an elastic IP to the network interface
# 9. Create Ubuntu server and install/enable apache2

provider "aws" {
  region = "us-east-1"
}

# 1. Create vpc
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

    tags = {
      Name = "my-vpc"
    }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "my-gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-gw"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "my-route-table" {
    vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.my-gw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my-subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow WEB inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet
resource "aws_network_interface" "my_network_interface" {
  subnet_id       = aws_subnet.my-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# 8. Assign an elastic IP to the network interface
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.my_network_interface.id
  #associate_with_private_ip = "10.0.1.50"
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "ubuntu" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "my_key"
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.my_network_interface.id
  }

  # user_data = <<-EOF
  #               #!/bin/bash
  #               sudo apt update -y
  #               sudo apt install apache2 -y
  #               sudo systemctl start apache2
  #               sudo bash -c 'echo your very first web server > /var/www/html/index.html'
  #               EOF

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y &&
                sudo apt install -y nginx
                echo "Hello World" > /var/www/html/index.html
                EOF

  tags = {
    Name = "ubuntu"
  }
}