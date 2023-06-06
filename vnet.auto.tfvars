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
        service_endpoints                              = ["Microsoft.KeyVault"]
        nsg_key                                        = "azure_kubernetes_cluster_nsg"
        enforce_private_link_endpoint_network_policies = true
      }
      private_endpoints = {
        name                                           = "private_endpoints"
        cidr                                           = ["10.0.238.0/24"]
        enforce_private_link_endpoint_network_policies = true
      }
      AzureBastionSubnet = {
        name    = "AzureBastionSubnet" #Must be called AzureBastionSubnet
        cidr    = ["10.0.239.0/24"]
        nsg_key = "azure_bastion_nsg"
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