#
# Services supported: subscriptions, storage accounts and resource groups
# Can assign roles to: AD groups, AD object ID, AD applications, Managed identities
#
role_mapping = {
  custom_role_mapping = {}

  built_in_role_mapping = {
    resource_groups = {
      network = {
        "Network Contributor" = {
          managed_identities = {
            keys = ["aks"]
          }
        }
      }
    }
  }
}