virtual_network_gateways = {
  main = {
    name                       = "main"
    resource_group_key         = "network"
    type                       = "Vpn"
    sku                        = "VpnGw1"
    private_ip_address_enabled = true
    # enable_bpg defaults to false. If set, true, input the necessary parameters as well. VPN Type only
    enable_bgp = false
    vpn_type   = "RouteBased"
    # multiple IP configs are needed for active_active state. VPN Type only.
    ip_configuration = {
      ipconfig1 = {
        ipconfig_name         = "gatewayIp1"
        public_ip_address_key = "vn_gw"
        vnet_key                      = "main"
        # private_ip_address_allocation = "Static"
      }
    }

    vpn_client_configuration = {
      # The following vpn client config allows AzureAD authentication together with certificate authentication
      vpnconfig1 = {
        address_space = ["10.1.0.0/16"]

        vpn_auth_types       = ["AAD"]
        vpn_client_protocols = ["OpenVPN"]

        aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" #Azure VPN Client ApplicationId
        aad_issuer   = "https://sts.windows.net/<tenantId>/"
        aad_tenant   = "https://login.microsoftonline.com/<tenantId>/"
      }
    }
  }
}