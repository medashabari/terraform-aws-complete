terraform {
  backend "s3" {
    bucket       = "terraform-backend-aws-1"
    key          = "dev/day7/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}