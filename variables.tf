variable "location" {
  description = "Azure Location for resources"
}

variable "subscription_name" {
  description = "Azure subscription name"
}

variable "name_prefix" {
  description = "Name prefix for all name"
  default     = "ANHQUACH"
}

variable "admin_username" {
  description = "Admin user for VMs"
  default     = "remote_admin"
}