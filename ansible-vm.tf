# Create resource group for ansible awx
resource "azurerm_resource_group" "ansible" {
  name     = "${local.name_prefix}-ansible"
  location = local.location

  lifecycle {
    ignore_changes = [tags]
  }
}

module "ansible" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name = azurerm_resource_group.ansible.name
  vm_name             = "ansible"
  location            = local.location
  subnet_id           = module.base_network.subnet_public_id
  os_type             = "linux"
  is_public           = true
  admin_username      = local.admin_username
  ssh_public_key      = module.linux_ssh_key.ssh_public_key
  os_image_publisher  = local.linux_os_image_info["publisher"]
  os_image_offer      = local.linux_os_image_info["offer"]
  os_image_sku        = local.linux_os_image_info["sku"]

    # Tag values
  tag_applicationRole = "ansible"

  depends_on = [
    module.base_network
  ]
}