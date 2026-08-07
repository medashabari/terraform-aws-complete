output "default_vpc_cidr" {
  value = data.aws_vpc.shared_vpc.cidr_block
}

output "default_vpc_subnet_a" {
  value = data.aws_subnet.shared_vpc_subnet_a.cidr_block
}

output "ami_id" {
  value = [data.aws_ami.amazon_linux_2.image_id]
}