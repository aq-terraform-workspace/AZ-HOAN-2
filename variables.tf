variable "location" {
  description = "Azure Location for resources"
}

variable "subscription_name" {
  description = "Azure subscription name"
  default     = ""
}

variable "name_prefix" {
  description = "Name prefix for all name"
  default     = "ANHQUACH"
}

variable "admin_username" {
  description = "Admin user for VMs"
  default     = "remote_admin"
}

variable "public_dns_zone_name" {
  description = "Public DNS Zone name"
  default     = ""
}

# variable "subscription_id" {
#   description = "Azure subscription ID"
# }

# variable "tenant_id" {
#   description = "Azure tenant ID"
# }