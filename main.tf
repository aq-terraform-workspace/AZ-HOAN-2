locals {
  # name_prefix = var.subscription_name
  name_prefix = var.name_prefix
  location = var.location
  admin_username = "remote_admin"
  bastion_os_image_info = {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter"
  }
}

data "azurerm_key_vault" "myvault" {
  name                = "${lower(local.name_prefix)}-keyvault"
  resource_group_name = "${local.name_prefix}-SVRG"
}

data "azurerm_storage_account" "example" {
  name                = "${lower(local.name_prefix)}storageaccount"
  resource_group_name = "${local.name_prefix}-SVRG"
}

# =================================== #
# PASSWORD AND SSH KEY GENERATION
# DO NOT DELETE
# =================================== #
# Push admin user to keyvault for later use
resource "azurerm_key_vault_secret" "linux-user" {
  key_vault_id         = data.azurerm_key_vault.myvault.id
  name                 = "admin-user"
  value                = var.admin_username

  tags = {
    Name        = "admin-user"
    DeployDate  = replace(timestamp(), "/T.*$/", "")
  }

  lifecycle {
    # Value should be ignore changes because our logic is to use the 1st init value only unless this resource is deleted
    ignore_changes = [tags, value]
  }
}

module "windows_password" {
  source  = "app.terraform.io/aq-tf-cloud/credential/azure"
  version = "1.0.0"
  type                = "password"
  secret_name         = "windows-admin-password"
  key_vault_id        = data.azurerm_key_vault.myvault.id
}

module "linux_ssh_key" {
  source  = "app.terraform.io/aq-tf-cloud/credential/azure"
  version = "1.0.0"
  type                  = "ssh"
  secret_name           = "linux-user-private-ssh-key"
  storage_account_name  = "${lower(local.name_prefix)}storageaccount"
  key_vault_id          = data.azurerm_key_vault.myvault.id
}
# =================================== #
# Create base network for all resources
module "base_network" {
  source  = "git::https://github.com/aq-terraform-modules/terraform-azure-base-network.git?ref=dev_new_approach"

  resource_group_name = "${local.name_prefix}-WLRG"
  virtual_network_name = "${local.name_prefix}-VNET"
  location = local.location
}

# Create K8S cluster using VMs
module "vm_k8s_cluster" {
  source  = "git::https://github.com/aq-terraform-modules/terraform-azure-vm-k8s-cluster.git?ref=dev"

  resource_group_name = "${local.name_prefix}-k8s"
  vm_name = "${local.name_prefix}-k8s"
  location = local.location
  subnet_id = module.base_network.subnet_private_id
  admin_username = local.admin_username
  ssh_public_key = module.linux_ssh_key.ssh_public_key
}

module "bastion_vm" {
  source  = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name = "${local.name_prefix}-bastion"
  vm_name = "${local.name_prefix}-bastion"
  location = local.location
  subnet_id = module.base_network.subnet_public_id
  os_type = "windows"
  is_public = true
  admin_username = local.admin_username
  admin_password = module.windows_password.Value
  os_image_publisher = local.bastion_os_image_info["publisher"]
  os_image_offer = local.bastion_os_image_info["offer"]
  os_image_sku = local.bastion_os_image_info["sku"]
}
