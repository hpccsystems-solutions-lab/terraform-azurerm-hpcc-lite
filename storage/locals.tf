locals {
  owner = {
    name  = var.aks_admin_name
    email = var.aks_admin_email
  }

  owner_name_initials = lower(join("",[for x in split(" ",local.owner.name): substr(x,0,1)]))

  get_vnet_config = fileexists("../vnet/data/config.json") ? jsondecode(file("../vnet/data/config.json")) : null

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
