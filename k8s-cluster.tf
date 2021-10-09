# Create K8S cluster using VMs
module "vm_k8s_cluster" {
  source = "git::https://github.com/aq-terraform-modules/terraform-azure-vm-k8s-cluster.git?ref=dev"

  resource_group_name = "${local.name_prefix}-k8s"
  location            = local.location
  subnet_id           = module.base_network.subnet_private_id
  admin_username      = local.admin_username
  ssh_public_key      = module.linux_ssh_key.ssh_public_key
  http_node_port      = 30004
  https_node_port     = 30735

  depends_on = [
    module.base_network
  ]
}

