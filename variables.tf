variable "location" {
  description = "Azure Location for resources"
}

variable "name_prefix" {
  description = "Name prefix for all name"
  default     = "ANHQUACH"
}

variable "admin_user" {
  description = "Admin user for VMs"
  default     = "remote_admin"
}