provider "aws" {
  region = "ap-southeast-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = ["sg-0f9066ea8751b5a06"]

  user_data = <<-EOF
              #!/bin/bash
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "Website deployed via Jenkins & Terraform" > /var/www/html/index.html
              EOF

  tags = {
    Name = "WebServer"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
