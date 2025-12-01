resource "aws_vpc" "custom-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    "Name" = local.vpc_name
  }
}

resource "aws_subnet" "public_zone" {
  vpc_id                  = aws_vpc.custom-vpc.id
  cidr_block              = var.vpc_public_subnet_cidr
  map_public_ip_on_launch = var.vpc_map_public_ip
}

resource "aws_instance" "new_ec2" {
  ami           = var.ec2_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public_zone.id

  tags = {
    Name = local.ec2_instance_name
  }
}