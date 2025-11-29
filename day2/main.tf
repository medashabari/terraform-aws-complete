resource "aws_instance" "ec2-instance" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  tags = {
    Name = "TerraformExampleInstance"
  }
}