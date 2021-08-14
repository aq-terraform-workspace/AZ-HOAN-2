# Create K8S cluster using VMs
/* module "vm_k8s_cluster" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-vm-k8s-cluster.git?ref=dev"

  resource_group_name = "${local.name_prefix}-k8s"
  vm_name             = "k8s"
  location            = local.location
  subnet_id           = module.base_network.subnet_private_id
  admin_username      = local.admin_username
  ssh_public_key      = module.linux_ssh_key.ssh_public_key

  depends_on = [
    module.base_network
  ]
} */

# Create resource group for bastion host
resource "azurerm_resource_group" "bastion_rg" {
  name     = "${local.name_prefix}-bastion"
  location = local.location

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create bastion host using windows VM
module "bastion_vm" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name = azurerm_resource_group.bastion_rg.name
  vm_name             = "bastion"
  location            = local.location
  subnet_id           = module.base_network.subnet_public_id
  os_type             = "windows"
  is_public           = true
  admin_username      = local.admin_username
  admin_password      = module.windows_password.value
  os_image_publisher  = local.windows_os_image_info["publisher"]
  os_image_offer      = local.windows_os_image_info["offer"]
  os_image_sku        = local.windows_os_image_info["sku"]

  # Tag values
  tag_applicationRole = "bastion"

  depends_on = [
    module.base_network
  ]
}