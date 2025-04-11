# Define the region for the AWS provider
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

# Define the Availability Zone
variable "availability_zone" {
  description = "The availability zone to launch the resources in."
  type        = string
  default     = "us-east-1a" 
}

# Define the AMI to be used for the EC2 instances
variable "ami_id" {
  description = "The AMI ID to be used for launching EC2 instances."
  type        = string
  default     = "ami-04b4f1a9cf54c11d0"
}

# Define the instance type for EC2 instances
variable "instance_type" {
  description = "The instance type for the EC2 instances."
  type        = string
  default     = "m7a.8xlarge"
}

variable "root_volume_size" {
  description = "The size of the root EBS volume in GiB"
  type        = number
  default     = "500"
}

variable "root_volume_type" {
  description = "The type of the root EBS volume (e.g., gp2, io1)"
  type        = string
  default     = "gp3"
}

