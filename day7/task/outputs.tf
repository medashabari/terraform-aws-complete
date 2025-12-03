output "vpc-name" {
  value = aws_vpc.dev-vpc.tags_all["Name"]
}

output "deployment_summary" {
  description = "Summary of the overall deployment"
  value = {
    Environment    = var.environment
    Instance_Count = var.instance_count
    Resource_Name  = var.tags["Name"]
  }
}