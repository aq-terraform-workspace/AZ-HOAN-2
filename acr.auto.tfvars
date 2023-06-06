azure_container_registries = {
  acr = {
    name               = "main"
    resource_group_key = "shared_svc"
    sku                = "Premium" # "Standard" # "Premium" #"Basic"

    private_endpoints = {
      # Require enforce_private_link_endpoint_network_policies set to true on the subnet
      acr = {
        name               = "acr"
        resource_group_key = "shared_svc"
        vnet_key           = "main"
        subnet_key         = "private_endpoints"

        private_service_connection = {
          name                 = "acr"
          is_manual_connection = false
          subresource_names    = ["registry"]
        }

        private_dns = {
          zone_group_name = "default"
          keys = ["acr"]
        }
      }
    }
  }
}