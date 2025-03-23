provider "aws" {
  region = "us-east-1"
}

# ✅ Protect this S3 bucket from accidental deletion
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket-12345"

  lifecycle {
    prevent_destroy = true
  }
}
