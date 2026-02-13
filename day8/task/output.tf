output "s3_bucket_info" {
  value = { for k,b in aws_s3_bucket.test_s3_buckets : k => b.bucket }
}

output "s3_bucket_info_for_each" {
  value = { for k,b in aws_s3_bucket.test_s3_buckets_for_each : k => b.bucket }
}