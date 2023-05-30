# https://github.com/aztfmod/terraform-azurerm-caf/commit/4c3965a7385ff6cf28b8894dbd0f94a56d117ae3
module "caf" {
  source  = "aztfmod/caf/azurerm"
  version = "5.6.9"


  global_settings = var.global_settings
  resource_groups = var.resource_groups
}
