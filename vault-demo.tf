# Vault cluster
module "vault_cluster" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name  = "${local.name_prefix}-vault"
  vm_name              = "vault-node"
  vm_count             = 3
  location             = local.location
  subnet_id            = module.base_network.subnet_public_id
  os_type              = "linux"
  is_public            = true
  admin_username       = local.admin_username
  ssh_public_key       = module.linux_ssh_key.ssh_public_key
  service_rg_name      = "${lower(local.name_prefix)}-SVRG"
  public_dns_zone_name = local.public_dns_zone_name
  os_image_publisher   = local.linux_os_image_info["publisher"]
  os_image_offer       = local.linux_os_image_info["offer"]
  os_image_sku         = local.linux_os_image_info["sku"]

  # Tag values
  tag_applicationRole = "bastion"

  depends_on = [
    module.base_network
  ]
}

# HA Proxy VM
module "ha_proxy" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name  = "${local.name_prefix}-ha-proxy"
  vm_name              = "ha-proxy"
  vm_count             = 1
  location             = local.location
  subnet_id            = module.base_network.subnet_public_id
  os_type              = "linux"
  is_public            = true
  admin_username       = local.admin_username
  ssh_public_key       = module.linux_ssh_key.ssh_public_key
  service_rg_name      = "${lower(local.name_prefix)}-SVRG"
  public_dns_zone_name = local.public_dns_zone_name
  os_image_publisher   = local.linux_os_image_info["publisher"]
  os_image_offer       = local.linux_os_image_info["offer"]
  os_image_sku         = local.linux_os_image_info["sku"]

  # Tag values
  tag_applicationRole = "bastion"

  depends_on = [
    module.base_network
  ]
}

# Windows 10 Client VM
module "client" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name  = "${local.name_prefix}-client"
  vm_name              = "client"
  vm_count             = 1
  location             = local.location
  subnet_id            = module.base_network.subnet_public_id
  os_type              = "windows"
  is_public            = true
  admin_username       = local.admin_username
  admin_password      = module.windows_password.value
  service_rg_name      = "${lower(local.name_prefix)}-SVRG"
  public_dns_zone_name = local.public_dns_zone_name
  os_image_publisher   = local.windows10_os_image_info["publisher"]
  os_image_offer       = local.windows10_os_image_info["offer"]
  os_image_sku         = local.windows10_os_image_info["sku"]

  # Tag values
  tag_applicationRole = "bastion"

  depends_on = [
    module.base_network
  ]
}