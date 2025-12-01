output "vpc_id" {
  value = "${local.vpc_name} - ${aws_vpc.custom-vpc.id}"
}

output "ec2_public_ip" {
  value = "${local.ec2_instance_name} - ${aws_instance.new_ec2.public_ip}"
}