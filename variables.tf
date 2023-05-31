#####################################
##    Global
#####################################
variable "global_settings" {
  default = {
    default_region = "primary"
    regions = {
      primary = "southeastasia"
    }
  }
}

variable "resource_groups" {
  default = {}
}

variable "tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}

#####################################
##    Networking
#####################################
variable "network_security_group_definition" {
  default = {}
}

variable "vnets" {
  default = {}
}

variable "public_ip_addresses" {
  default = {}
}

variable "virtual_network_gateways" {
  default = {}
}

variable "private_dns" {
  default = {}
}

#####################################
##    Compute
#####################################
variable "azure_container_registries" {
  default = {}
}

variable "aks_clusters" {
  default = {}
}

#####################################
##    Others
#####################################
variable "keyvaults" {
  default = {}
}

variable "managed_identities" {
  default = {}
}

variable "role_mapping" {
  default = {}
}