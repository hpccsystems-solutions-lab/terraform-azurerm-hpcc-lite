locals {
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

  get_vnet_config = fileexists("../vnet/data/config.json") ? jsondecode(file("../vnet/data/config.json")) : null
  # get_aks_config  = fileexists("../aks/data/config.json") ? jsondecode(file("../aks/data/config.json")) : null

  virtual_network = var.virtual_network != null ? var.virtual_network : [
    {
      vnet_name           = local.get_vnet_config.name
      resource_group_name = local.get_vnet_config.resource_group_name
      subnet_name         = local.get_vnet_config.private_subnet_name
      subscription_id     = null
    }
  ]

  subnet_ids = [
    for v in local.virtual_network : "/subscriptions/${v.subscription_id != null ? v.subscription_id : data.azurerm_client_config.current.subscription_id}/resourceGroups/${v.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${v.vnet_name}/subnets/${v.subnet_name}"
  ]
}
