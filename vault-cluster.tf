
# Create bastion host using windows VM
module "vault_cluster" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name  = "${local.name_prefix}-bastion"
  vm_name              = "vault-node"
  vm_count             = 3
  location             = local.location
  subnet_id            = module.base_network.subnet_public_id
  os_type              = "linux"
  is_public            = true
  admin_username       = local.admin_username
  ssh_public_key       = module.linux_ssh_key.value
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