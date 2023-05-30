global_settings = {
  default_region = "primary"
  regions = {
    primary = "southeastasia"
  }
  prefix       = "prefect2-dev"
  inherit_tags = true
}

resource_groups = {
  # -- For network management purpose
  network = {
    name   = "network"
    region = "primary"
  }

  # -- For managing AKS resources
  aks = {
    name   = "aks"
    region = "primary"
  }
  shared_svc = {
    name   = "shared-svc"
    region = "primary"
  }
}

tags = {
  "environment" = "dev"
  "project"     = "prefect2"
}