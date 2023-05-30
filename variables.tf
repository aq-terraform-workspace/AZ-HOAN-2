#####################################
##    Global
#####################################
variable "global_settings" {
  default = {
    default_region = "primary"
    regions = {
      primary   = "southeastasia"
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