variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "my-unique-bucket-123345678-testing-tf"
  
}
variable "random_suffix" {
  description = "Random suffix to ensure unique bucket name"
  type        = string
  default     = "2781772"
}