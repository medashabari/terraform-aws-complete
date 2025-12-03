variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "region" {
  type        = string
  description = "Deployment Region"
  default     = "us-east-1"

  validation {
    condition     = contains(var.allowed_region, var.region)
    error_message = "The region '${var.region}' is not allowed. Please choose one of: ${join(", ", var.allowed_region)}."
  }
}

variable "instance_count" {
  type        = number
  description = "Instance count"
  default     = 1
}

variable "monitoring_enabled" {
  type        = bool
  description = "Monitoring enabled"
  default     = true
}

variable "associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP address"
  default     = true
}

variable "cidr_block" {
  type        = list(string)
  description = "Cidr blocks for vpc"
  default     = ["10.0.0.0/16", "192.168.0.0/16", "172.16.0.0/12"]
}

variable "allowed_vm_types" {
  type        = list(string)
  description = "Allow VM types"
  default     = ["t2.micro", "t2.small", "t3.micro", "t3.small"]
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t3.micro", "t3.small"], var.instance_type)
    error_message = "Instance type must be one of t2.micro, t2.small, t3.micro, t3.small."
  }
}

variable "allowed_region" {
  type        = set(string)
  description = "allowed regions"
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

variable "tags" {
  type        = map(string)
  description = "tags"
  default = {
    Environment = "dev",
    Name        = "dev-Instance",
    created_by  = "terraform"
  }
}

variable "ingress_values" {
  type        = tuple([number, string, number])
  description = "Ingress values"
  default     = [443, "tcp", 443]
}

variable "config" {
  type = object({
    region         = string
    monitoring     = bool
    instance_count = number
  })
  default = { region = "us-east-1", monitoring = true, instance_count = 1 }

}