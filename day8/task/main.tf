resource "aws_s3_bucket" "test_s3_buckets" {
  count = 2
  bucket = "my-bucket-${count.index}"
}

resource "aws_s3_bucket" "test_s3_buckets_for_each" {
  for_each = var.bucket_names
  bucket = each.value
}