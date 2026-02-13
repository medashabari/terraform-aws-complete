resource "aws_s3_bucket" "critical_bucket" {
  bucket = "my_critical_bucket"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  tags = {
    Name = "TerraformExampleInstance"
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_alb" "custom_alb" {
  count = 1
  name = "cusotm alb"
}

resource "aws_alb_target_group" "alb_tg" {
  name= "alb_tg"
}

resource "aws_alb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_alb_target_group.alb_tg.arn
  target_id = aws_instance.web_server.id
}
resource "aws_autoscaling_group" "my_asg" {
  max_size = 2
  min_size = 1
  desired_capacity = 1

  load_balancers = [ aws_alb.custom_alb ]

  lifecycle {
    ignore_changes = [ desired_capacity, # Ignore capacity changes by auto-scaling
                        load_balancers,    # Ignore if added externally 
                    ]
#                     **Special Values:**
# - `ignore_changes = all` - Ignore ALL attribute changes
# - `ignore_changes = [tags]` - Ignore only tags

  }
}

resource "aws_security_group" "app_sg" {
  name = "app-security-group"
  # ... security rules ...
}

resource "aws_instance" "app_with_sg" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  lifecycle {
    replace_triggered_by = [
      aws_security_group.app_sg.id  # Replace instance when SG changes
    ]
  }
}


resource "aws_s3_bucket" "regional_validation" {
  bucket = "validated-region-bucket"

  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, data.aws_region.current.name)
      error_message = "ERROR: Can only deploy in allowed regions: ${join(", ", var.allowed_regions)}"
    }
  }
}

resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliance-bucket"

  tags = {
    Environment = "production"
    Compliance  = "SOC2"
  }

  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "ERROR: Bucket must have a 'Compliance' tag!"
    }

    postcondition {
      condition     = contains(keys(self.tags), "Environment")
      error_message = "ERROR: Bucket must have an 'Environment' tag!"
    }
  }
}