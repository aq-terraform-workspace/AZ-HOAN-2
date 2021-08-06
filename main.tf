data "azurerm_key_vault" "myvault" {
  name                = "${lower(var.name_prefix)}-keyvault"
  resource_group_name = "${var.name_prefix}-SVRG"
}

data "azurerm_storage_account" "example" {
  name                = "${lower(var.name_prefix)}storageaccount"
  resource_group_name = "${var.name_prefix}-SVRG"
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

module "windows-password" {
  source  = "app.terraform.io/aq-tf-cloud/credential/azure"
  version = "1.0.2"
  type                = "password"
  secret_name         = "windows-admin-password"
  key_vault_id        = data.azurerm_key_vault.myvault.id
}

module "linux-ssh-key" {
  source  = "app.terraform.io/aq-tf-cloud/credential/azure"
  version = "1.0.2"
  type                  = "ssh"
  secret_name           = "linux-user-private-ssh-key"
  storage_account_name  = "${lower(var.name_prefix)}storageaccount"
  key_vault_id          = data.azurerm_key_vault.myvault.id
}
# =================================== #
