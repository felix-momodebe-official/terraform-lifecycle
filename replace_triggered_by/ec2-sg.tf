provider "aws" {
  region = "us-east-1"
}

# ✅ Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for web server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ EC2 instance that REPLACES if security group changes
resource "aws_instance" "app_server" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  lifecycle {
    replace_triggered_by = [aws_security_group.web_sg]
  }

  tags = {
    Name = "App Server"
  }
}
