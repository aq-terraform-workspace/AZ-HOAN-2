vnets = {
  main = {
    resource_group_key = "network" # -- Reference resource group kyes in global.auto.tfvars
    vnet = {
      name          = "main"
      address_space = ["10.0.0.0/16"]
    }
    subnets = {
      aks = {
        name                                           = "aks"
        cidr                                           = ["10.0.0.0/20"]
        enforce_private_link_endpoint_network_policies = true
      }
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" # must be named GatewaySubnet
        cidr = ["10.0.240.0/20"]
      }
    }
  }
}