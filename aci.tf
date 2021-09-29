/* module "pierrecardinvn_aci" {
  source = "git::https://github.com/aq-terraform-modules/terraform-aci.git?ref=dev"

  resource_group_name  = "pierrecardinvn.com"
  location             = local.location
  aci_name             = "pierrecardinvn.com"
  dns_name_label       = "pierrecardinvn"
  container_name       = "aapanel"
  container_image      = "sheid1309/aapanel:1.3"
  cpu                  = "2.5"
  memory               = "3"
  storage_account_name = "pierrecardindata"

  container_ports = [
    {
      port     = 80
      protocol = "TCP"
    },
    {
      port     = 443
      protocol = "TCP"
    },
    {
      port     = 888
      protocol = "TCP"
    },
    {
      port     = 8888
      protocol = "TCP"
    }
  ]

  environment_variables = {
    PANEL_PORT = 8888
  }

  secure_environment_variables = {
    PANEL_PWD = "p@ssw0rd"
  }
} */