provider "aws" {
  region = "us-east-1"
}

# ✅ Ignore changes to instance type (Terraform won’t override manual updates)
resource "aws_instance" "dev_server" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"

  lifecycle {
    ignore_changes = [instance_type]
  }

  tags = {
    Name = "Dev Server"
  }
}
