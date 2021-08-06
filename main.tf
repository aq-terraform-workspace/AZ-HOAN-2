resource "azurerm_resource_group" "test-rg" {
  name      = "Terraform Test RG"
  location  = local.location
}