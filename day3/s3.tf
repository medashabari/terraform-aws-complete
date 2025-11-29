resource "aws_s3_bucket" "my_bucket" {
  bucket = "aws-shabarish-meda-bucket-2025"

  # Create implicit dependency
  tags = {
    CreatedInVpc = aws_vpc.custom_vpc.id
  }
}