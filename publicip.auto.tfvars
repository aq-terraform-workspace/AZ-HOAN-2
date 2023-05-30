public_ip_addresses = {
  vngw = {
    name                    = "vngw"
    region                  = "primary"
    resource_group_key      = "network"
    sku                     = "Basic"
    allocation_method       = "Dynamic"
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
  }
}
