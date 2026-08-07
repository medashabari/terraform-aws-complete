data "aws_vpc" "shared_vpc" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_subnet" "shared_vpc_subnet_a" {
  filter {
    name = "tag:Name"
    values = ["subnet-us-east-1a"]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "test_instance" {
  ami = data.aws_ami.amazon_linux_2.image_id
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.shared_vpc_subnet_a.id
  availability_zone = data.aws_subnet.shared_vpc_subnet_a.availability_zone
  associate_public_ip_address = false
  root_block_device {
    volume_size = "8"
  }
}