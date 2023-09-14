provider "aws" {
  region = "eu-central-1"
}

variable "vpc_network" {}
variable "public_sn_IP" {}
variable "private_sn_IP" {}
variable "default_route" {}
variable "instances" {}
variable "availability_zone" {}

# https://www.youtube.com/watch?v=aOVdNAE2Jeg
# PLAN FOR BASTION HOST
# 1x VPC
# 2x Subnet - public, private
# IGW for public subnet
# 2x Route table (pub,pri) -> Route Table Association
# Security group
# bastion instance -> Interface -> EIP - EIP assoc
# private instance -> Interface
# NAT Gateway in pub -> EIP - EIP assoc

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_network

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "bastion_public_sn" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_sn_IP
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "bastion_public_sn"
  }
}

resource "aws_subnet" "bastion_private_sn" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_sn_IP
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "private_sn"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "bastion_igw"
  }
}
#############################   ROUTE TABLES   ##############################################

resource "aws_route_table" "bastion_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.default_route[0]
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = var.default_route[1]
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "bastion_rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.bastion_public_sn.id
  route_table_id = aws_route_table.bastion_rt.id
}

####

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.default_route[0]
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.bastion_private_sn.id
  route_table_id = aws_route_table.private_rt.id
}
###############################   SECURITY GROUP   ############################################

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.default_route[0]]
    ipv6_cidr_blocks = [var.default_route[1]]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.default_route[0]]
    ipv6_cidr_blocks = [var.default_route[1]]
  }

  tags = {
    Name = "allow_ssh_bastion"
  }
}
##########################  INSTANCES   ##########################################

resource "aws_network_interface" "bastion_interface" {
  subnet_id       = aws_subnet.bastion_public_sn.id
  security_groups = [ aws_security_group.allow_ssh.id ]

  tags = {
    Name = "bastion_interface"
  }
}

resource "aws_eip" "bastion_eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.bastion_interface.id
}

resource "aws_instance" "bastion" {
  ami           = var.instances[0].ami
  instance_type = var.instances[0].instance_type
  key_name = var.instances[0].key_name
  availability_zone = var.availability_zone

  network_interface {
    network_interface_id = aws_network_interface.bastion_interface.id
    device_index         = 0
  }

  tags = {
    Name = "bastion"
  }
}

####

resource "aws_network_interface" "prv_instance_interface" {
  subnet_id       = aws_subnet.bastion_private_sn.id
  security_groups = [ aws_security_group.allow_ssh.id ]
  tags = {
    Name = "prv_instance_interface"
  }
}

resource "aws_instance" "private_instance" {
  ami           = var.instances[1].ami
  instance_type = var.instances[1].instance_type
  key_name = var.instances[1].key_name
  availability_zone = var.availability_zone

  network_interface {
    network_interface_id = aws_network_interface.prv_instance_interface.id
    device_index         = 0
  }

  tags = {
    Name = "private_instance"
  }
}

############################### NAT GATEWAY  #####################################

resource "aws_eip" "nat_eip" {
  domain                    = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.bastion_public_sn.id

  tags = {
    Name = "nat_gateway"
  }

  #depends_on = [ aws_internet_gateway.igw ]
}

