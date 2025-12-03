# task 1

resource "aws_s3_bucket" "dev_s3_bucket" {
  bucket = "${var.environment}-shabarishtestbucket1234567#"
}


# task 2 and 3
resource "aws_instance" "dev_ec2_instance" {
  count                       = var.instance_count
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type               = var.instance_type
  monitoring                  = var.monitoring_enabled
  associate_public_ip_address = var.associate_public_ip
  tags = {
    Name = "${var.environment}-ec2-instance-${count.index + 1}"
  }

  lifecycle {
    precondition {
      condition     = contains(var.allowed_vm_types, var.instance_type)
      error_message = "Instance type ${var.instance_type} is not allowed."
    }
  }
}

# task 4
resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr_block[0]
  tags       = var.tags
}

resource "aws_subnet" "dev-vpc-subnet-1" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.cidr_block[1]
}

resource "aws_subnet" "dev-vpc-subnet-2" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.cidr_block[2]
}

resource "aws_security_group" "dev-security-grp" {
  vpc_id = aws_vpc.dev-vpc.id
  tags   = var.tags

  ingress {
    from_port   = var.ingress_values[0]
    to_port     = var.ingress_values[2]
    protocol    = var.ingress_values[1]
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dev_ec2_instance-1" {
  count                       = var.config.instance_count
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type               = var.instance_type
  monitoring                  = var.config.monitoring
  associate_public_ip_address = var.associate_public_ip
  tags = {
    Name = "${var.environment}-ec2-instance-${count.index + 1}"
  }

  lifecycle {
    precondition {
      condition     = contains(var.allowed_vm_types, var.instance_type)
      error_message = "Instance type ${var.instance_type} is not allowed."
    }
  }
}