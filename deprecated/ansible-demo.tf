/* # Create domain controllers using windows VM
module "dc" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  vm_count            = 2
  resource_group_name = "${local.name_prefix}-dc"
  vm_name             = "dc"
  location            = local.location
  subnet_id           = module.base_network.subnet_private_id
  os_type             = "windows"
  is_public           = false
  admin_username      = local.admin_username
  admin_password      = module.windows_password.value
  os_image_publisher  = local.windows_os_image_info["publisher"]
  os_image_offer      = local.windows_os_image_info["offer"]
  os_image_sku        = local.windows_os_image_info["sku"]

  # Tag values
  tag_applicationRole = "dc"

  depends_on = [
    module.base_network
  ]
}

module "client_windows" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name = "${local.name_prefix}-clients"
  vm_name             = "win-client"
  location            = local.location
  subnet_id           = module.base_network.subnet_private_id
  os_type             = "windows"
  is_public           = false
  admin_username      = local.admin_username
  admin_password      = module.windows_password.value
  os_image_publisher  = local.windows_os_image_info["publisher"]
  os_image_offer      = local.windows_os_image_info["offer"]
  os_image_sku        = local.windows_os_image_info["sku"]

  # Tag values
  tag_applicationRole = "client"

  depends_on = [
    module.base_network
  ]
}

module "client_linux" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name = "${local.name_prefix}-clients"
  create_rg           = false
  vm_name             = "linux-client"
  location            = local.location
  subnet_id           = module.base_network.subnet_private_id
  os_type             = "linux"
  is_public           = false
  admin_username      = local.admin_username
  ssh_public_key      = module.linux_ssh_key.ssh_public_key
  os_image_publisher  = local.linux_os_image_info["publisher"]
  os_image_offer      = local.linux_os_image_info["offer"]
  os_image_sku        = local.linux_os_image_info["sku"]

  # Tag value
  tag_applicationRole = "client"

  depends_on = [
    module.base_network
  ]
} */
