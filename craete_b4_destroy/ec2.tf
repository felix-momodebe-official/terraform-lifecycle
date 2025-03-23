provider "aws" {
  region = "us-east-1"
}

# ✅ Create an EC2 instance that gets replaced without downtime
resource "aws_instance" "web_server" {
  ami           = "ami-084568db4383264d4"  # Example Ubuntu AMI
  instance_type = "t2.small"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Web Server"
  }

}

  output "public_ip" {
    value = aws_instance.web_server.public_ip
}



