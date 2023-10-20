locals {
  internal_domain = var.aks_dns_zone_name

  dns_resource_group = var.aks_dns_zone_resource_group_name

  owner = {
    name  = var.aks_admin_name
    email = var.aks_admin_email
  }

  owner_name_initials = lower(join("",[for x in split(" ",local.owner.name): substr(x,0,1)]))

  metadata = {
    project             = format("%shpccplatform", local.owner_name_initials)
    product_name        = format("%shpccplatform", local.owner_name_initials)
    business_unit       = "commercial"
    environment         = "sandbox"
    market              = "us"
    product_group        = format("%shpcc", local.owner_name_initials)
    resource_group_type = "app"
    sre_team            = format("%shpccplatform", local.owner_name_initials)
    subscription_type   = "dev"
    additional_tags     = { "justification" = "testing" }
    location            = var.aks_azure_region # Acceptable values: eastus, centralus
  }

  core_services_config = {
    alertmanager = {
      smtp_host = "smtp-hostname.ds:25"
      smtp_from = var.aks_admin_email
      routes    = []
      receivers = []
    }

    # coredns = {
    #   forward_zones = {
    #     "" = ""
    #   }
    # }
    coredns = {}

    external_dns = {
      public_domain_filters = [var.aks_dns_zone_name]
    }

    # cert_manager = {
    #   acme_dns_zones      = [var.aks_dns_zone_name]
    #   default_issuer_name = "zerossl"
    # }
    cert_manager = {}

    ingress_internal_core = {
      domain           = var.aks_dns_zone_name
      subdomain_suffix = "hpcc" // dns record suffix //must be unique accross subscription
      public_dns       = true
    }
  }
}
