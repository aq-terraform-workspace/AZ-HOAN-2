# https://github.com/aztfmod/terraform-azurerm-caf/commit/4c3965a7385ff6cf28b8894dbd0f94a56d117ae3
module "azcli" {
  source = "./modules/azcli"
}

module "caf" {
  source  = "aztfmod/caf/azurerm"
  version = "5.6.9"

  providers = {
    azurerm.vhub = azurerm.vhub
  }

  global_settings = var.global_settings
  resource_groups = var.resource_groups

  # Others
  keyvaults          = var.keyvaults
  managed_identities = var.managed_identities
  role_mapping       = var.role_mapping

  # Networking
  networking = {
    network_security_group_definition = var.network_security_group_definition
    vnets                             = var.vnets
    public_ip_addresses               = var.public_ip_addresses
    virtual_network_gateways          = var.virtual_network_gateways
    private_dns                       = var.private_dns
    # route_tables = var.route_tables
    # azurerm_routes = var.azurerm_routes
    # Nat GateWay
    # nat_gateways = var.nat_gateways
  }

  compute = {
    azure_container_registries = var.azure_container_registries
    aks_clusters               = var.aks_clusters
  }

  tags = merge(
    module.azcli.depend_value,
    var.tags
  )
}
