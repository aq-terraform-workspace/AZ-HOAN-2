keyvaults = {
  main = {
    name               = "main"
    resource_group_key = "shared_svc"
    sku_name           = "premium"

    # Make sure you set a creation policy.
    creation_policies = {
      logged_in_user = {
        key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey"]
        certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
        secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
      }
    }

    network = {
      bypass         = "AzureServices"
      default_action = "Deny"
      subnets = {
        subnet1 = {
          vnet_key   = "main"
          subnet_key = "aks"
        }
      }
    }

    # private_endpoints = {
    #   # Require enforce_private_link_endpoint_network_policies set to true on the subnet
    #   private-link1 = {
    #     name               = "keyvault-certificates"
    #     vnet_key           = "vnet_security"
    #     subnet_key         = "private_link"
    #     resource_group_key = "kv_region1"

    #     private_service_connection = {
    #       name                 = "keyvault-certificates"
    #       is_manual_connection = false
    #       subresource_names    = ["vault"]
    #     }

    #     # private_dns = {
    #     #   dns1 = {
    #     #     lz_key          = ""
    #     #     private_dns_key = ""
    #     #   }
    #     # }
    #   }
    # }
  }
}