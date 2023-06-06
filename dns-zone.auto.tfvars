
private_dns = {
  keyvault = {
    name               = "privatelink.vaultcore.azure.net"
    resource_group_key = "shared_svc"
    vnet_links = {
      main = {
        name                 = ""
        vnet_key             = "main"
        registration_enabled = false
      }        
    }
  }
  blob = {
    name               = "privatelink.blob.core.windows.net"
    resource_group_key = "shared_svc"
    vnet_links = {
      main = {
        name                 = "main"
        vnet_key             = "main"
        registration_enabled = false
      }        
    }
  }
  acr = {
    name               = "privatelink.azurecr.io"
    resource_group_key = "shared_svc"
    vnet_links = {
      main = {
        name                 = "main"
        vnet_key             = "main"
        registration_enabled = false
      }        
    }
  }
  dns1 = {
    name               = "prefect2.local"
    resource_group_key = "shared_svc"

    # records = {
    #   cname_records = {
    #     cname_prefect1 = {
    #       name    = "www-cname-prefect1"
    #       records = "www.cname-prefect1.fsoft"
    #       ttl     = 3600
    #     }
    #     cname_prefect2 = {
    #       name    = "www-cname_prefect2"
    #       records = "www.cname_prefect2.fsoft"
    #       ttl     = 3600
    #     }
    #     cname_prefect3 = {
    #       name    = "www-cname_prefect3"
    #       records = "www.cname_prefect3.fsoft"
    #       ttl     = 3600
    #     }
    #   }
    #   a_records = {
    #     a_prefect1 = {
    #       name    = "a_prefect1"
    #       ttl     = 3600
    #       records = ["1.1.1.1"]
    #     }
    #     a_prefect2 = {
    #       name    = "a_prefect2"
    #       ttl     = 3600
    #       records = ["2.2.2.2"]
    #     }
    #     a_prefect3 = {
    #       name    = "a_prefect3"
    #       ttl     = 3600
    #       records = ["3.3.3.3"]
    #     }
    #   }
    # }

    vnet_links = {
      main = {
        name                 = "main"
        vnet_key             = "main"
        registration_enabled = true
      }        
    }
  }
}