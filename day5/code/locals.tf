locals {
  environment       = "Dev"
  ec2_instance_name = "${local.environment}-EC2-instance"
  vpc_name          = "${local.environment}-VPC"
}