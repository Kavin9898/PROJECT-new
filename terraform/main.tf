terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_vpc" "instance_vpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "instance-vpc"
  }
}

resource "aws_subnet" "instance_subnet" {
  vpc_id                  = aws_vpc.instance_vpc.id
  cidr_block              = "192.168.0.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "instance-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.instance_vpc.id

  tags = {
    Name = "instance-igw"
  }
}

resource "aws_route_table" "instance_route" {
  vpc_id = aws_vpc.instance_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "instance-route"
  }
}

resource "aws_route_table_association" "rt_assoc" {
  subnet_id      = aws_subnet.instance_subnet.id
  route_table_id = aws_route_table.instance_route.id
}

resource "aws_security_group" "instance_sg" {
  name   = "instance-sg"
  vpc_id = aws_vpc.instance_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.instance_subnet.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  associate_public_ip_address = true
  key_name = var.key_name

  user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
cd /var/www/html
rm -rf *

git clone https://github.com/Kavin9898/PROJECT-new.git temp
mv temp/* .
rm -rf temp
EOF

  tags = {
    Name = "Terraform-Instance"
  }
}
