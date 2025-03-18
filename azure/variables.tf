# variables.tf
variable "location" {
  description = "Azure region for resources"
  default     = "eastus"
}

variable "admin_username" {
  description = "Admin username for the VM"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  default = "Amd@@32!"
  sensitive   = true  
}