
# Create bastion host using windows VM
/* module "bastion_vm" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-simple-vm.git?ref=dev"

  resource_group_name  = "${local.name_prefix}-bastion"
  vm_name              = "bastion"
  location             = local.location
  subnet_id            = module.base_network.subnet_public_id
  os_type              = "windows"
  is_public            = true
  admin_username       = local.admin_username
  admin_password       = module.windows_password.value
  service_rg_name      = "${lower(local.name_prefix)}-SVRG"
  public_dns_zone_name = local.public_dns_zone_name
  os_image_publisher   = local.windows_os_image_info["publisher"]
  os_image_offer       = local.windows_os_image_info["offer"]
  os_image_sku         = local.windows_os_image_info["sku"]

  # Tag values
  tag_applicationRole = "bastion"

  depends_on = [
    module.base_network
  ]
} */