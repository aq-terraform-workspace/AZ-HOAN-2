locals {
  # name_prefix = var.subscription_name
  name_prefix    = var.name_prefix
  location       = var.location
  admin_username = "remote_admin"
  windows_os_image_info = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
  }
  linux_os_image_info = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
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
  key_vault_id = data.azurerm_key_vault.myvault.id
  name         = "admin-user"
  value        = var.admin_username

  tags = {
    Name       = "admin-user"
    DeployDate = replace(timestamp(), "/T.*$/", "")
  }

  lifecycle {
    # Value should be ignore changes because our logic is to use the 1st init value only unless this resource is deleted
    ignore_changes = [tags, value]
  }
}

module "windows_password" {
  source       = "app.terraform.io/aq-tf-cloud/credential/azure"
  version      = "1.0.0"
  type         = "password"
  secret_name  = "windows-admin-password"
  key_vault_id = data.azurerm_key_vault.myvault.id
}

module "linux_ssh_key" {
  source               = "app.terraform.io/aq-tf-cloud/credential/azure"
  version              = "1.0.0"
  type                 = "ssh"
  secret_name          = "linux-user-private-ssh-key"
  storage_account_name = "${lower(local.name_prefix)}storageaccount"
  key_vault_id         = data.azurerm_key_vault.myvault.id
}
# =================================== #
# Create base network for all resources
module "base_network" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-base-network.git?ref=dev_new_approach"

  resource_group_name  = "${local.name_prefix}-WLRG"
  virtual_network_name = "${local.name_prefix}-VNET"
  location             = local.location
}

# Create resource group for ansible awx
resource "azurerm_resource_group" "ansible" {
  name     = "${local.name_prefix}-ansible"
  location = local.location

  tags = {
    applicationRole = "ansible"
  }

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

  tags = {
    applicationRole = "ansible"
    os              = "linux"
  }

  depends_on = [
    module.base_network
  ]
}

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
}

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

  depends_on = [
    module.base_network
  ]
} */

# Create resource group for domain controller
/* resource "azurerm_resource_group" "dc_rg" {
  name     = "${local.name_prefix}-dc"
  location = local.location

  tags = {
    applicationRole = "dc"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create domain controllers using windows VM
module "dc" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  vm_count            = 2
  resource_group_name = azurerm_resource_group.dc_rg.name
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

  tags = {
    applicationRole = "dc"
    os              = "windows"
  }

  depends_on = [
    module.base_network
  ]
}

# Create resource group for client VM that will connect to the AD
resource "azurerm_resource_group" "clients" {
  name     = "${local.name_prefix}-clients"
  location = local.location

  tags = {
    applicationRole = "client"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

module "client_windows" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name = azurerm_resource_group.clients.name
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

  tags = {
    applicationRole = "client"
    os              = "windows"
  }

  depends_on = [
    module.base_network
  ]
}

module "client_linux" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name = azurerm_resource_group.clients.name
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

  tags = {
    applicationRole = "client"
    os              = "linux"
  }

  depends_on = [
    module.base_network
  ]
} */
