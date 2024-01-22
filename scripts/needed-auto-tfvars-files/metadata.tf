locals {
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
    location            = var.aks_azure_region # Acceptable values: eastus, centralus
    #additional_tags     = {}
  }
}
