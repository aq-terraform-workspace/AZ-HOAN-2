aks_clusters = {
  main = {
    name               = "main"
    resource_group_key = "aks"
    os_type            = "Linux"
    # The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, and Standard (which includes the Uptime SLA). Defaults to Free.
    sku_tier           = "Free"

    # -- identity
    # type - possible values [SystemAssigned, UserAssigned]. If [UserAssigned] is set, a user_assigned_identity_id must be set as well.
    # user_assigned_identity_id - (Optional) The ID of a user assigned identity.
    identity = {
      # type = "SystemAssigned"
      type                 = "UserAssigned"
      managed_identity_key = "aks"
    }

    kubernetes_version = "1.26"

    vnet_key = "main"

    # -- Network plugin to use for networking. If network_profile is not defined, kubenet profile will be used by default
    network_profile = {
      # -- (Required) Network plugin to use for networking. Currently supported values are [azure] and [kubenet]
      network_plugin = "azure"
      # -- (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are [calico] and [azure]. 
      network_policy = "azure"

      # dns_service_ip     = "172.20.0.10"   # (Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns).
      # docker_bridge_cidr = "10.100.0.0/16"  # (Optional) IP address (in CIDR notation) used as the Docker bridge IP address on nodes.
      # service_cidr       = "172.20.0.0/16" # (Optional) The Network Range used by the Kubernetes service.
      load_balancer_sku  = "Standard"       # (Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are Basic and Standard. Defaults to Standard.
      # outbound_type           = "userDefinedRouting"
      load_balancer_profile = {
        # Only one option can be set
        managed_outbound_ip_count = 1
        # outbound_ip_prefix_ids = []
        # outbound_ip_address_ids = []
      }
    }

    private_cluster_enabled             = true # Enable private cluster only have VPN or Bastion can reach to them
    private_cluster_public_fqdn_enabled = true

    # -- Role based access contorl configuration
    role_based_access_control = {
      enabled                = true
      azure_active_directory = []
    }

    admin_groups = {
      # ids = []
      # azuread_group_keys = ["aks_admins"]
    }

    auto_scaler_profile = {
      # Check the default value here 
      # https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler
      balance_similar_node_groups      = false
      expander                         = "random"
      max_graceful_termination_sec     = "600"
      max_node_provisioning_time       = "15m"
      max_unready_nodes                = "3"
      max_unready_percentage           = "45"
      new_pod_scale_up_delay           = "10s"
      scale_down_delay_after_add       = "10m"
      scale_down_delay_after_delete    = "10s" # Defaults to the value used for scan_interval
      scale_down_delay_after_failure   = "3m"
      scan_interval                    = "10s"
      scale_down_unneeded              = "10m"
      scale_down_unready               = "20m"
      scale_down_utilization_threshold = "0.5"
      empty_bulk_delete_max            = "10"
      skip_nodes_with_local_storage    = true
      skip_nodes_with_system_pods      = true
    }
    # -- The name of the Resource Group where the Kubernetes Nodes should exist.
    node_resource_group_name = "aks-nodes"

    default_node_pool = {
      name                  = "systempool"
      vm_size               = "Standard_B2s"
      type                  = "VirtualMachineScaleSets"
      os_disk_type          = "Managed" # (Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created.
      os_disk_size_gb       = 128
      availability_zones    = ["1", "2", "3"] # (Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created.
      enable_auto_scaling   = true            # Enable option auto scaling for min/max node per AKS cluster
      enable_node_public_ip = false
      node_count            = 1   # The initial number of nodes which should exist in this Node Pool
      min_count             = 1   # The minimum number of nodes which should exist in this Node Pool
      max_count             = 10 # The maximum number of nodes which should exist in this Node Pool
      max_pods              = 128 # The maximum number of pods that can run on each agent

      # -- (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist.
      subnet_key = "aks"
    }

    # node_pools = {
    #   spot_pool_1 = {
    #     name = "spotpool1"
    #     mode = "User"
    #     # -- Limnitation: The requested size for resource in location 'southeastasia' zones '1,2,3' for subscription '6df3bb9a-b876-43ee-86b3-dbd691daddcc not available
    #     # -> Maybe  due to trial subscription
    #     # priority              = "Spot" # The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool
    #     vm_size               = "Standard_B2ms"
    #     os_disk_type          = "Managed" # (Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created.
    #     os_disk_size_gb       = 128
    #     availability_zones    = ["1", "2", "3"] # (Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created.
    #     enable_auto_scaling   = true
    #     enable_node_public_ip = false
    #     spot_max_price        = -1 # The maximum price you're willing to pay in USD per Virtual Machine
    #     node_count            = 1
    #     node_taints           = []  # (Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). 
    #     min_count             = 3   # The minimum number of nodes which should exist in this Node Pool
    #     max_count             = 100 # The maximum number of nodes which should exist in this Node Pool
    #     max_pods              = 128

    #     # -- (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist.
    #     subnet_key = "aks"

    #     # -- (Optional) A mapping of tags to assign to the Node Pool.
    #     tags = {
    #       "project" = "user services"
    #     }
    #   }
    # }
  }
}
