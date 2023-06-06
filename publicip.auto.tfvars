public_ip_addresses = {
  vngw = {
    name                    = "vn-gw"
    resource_group_key      = "network"
    sku                     = "Standard"
    allocation_method       = "Static"
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
    zones                   = []
  }
}
