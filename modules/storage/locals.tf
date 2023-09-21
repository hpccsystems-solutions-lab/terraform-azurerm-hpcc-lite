locals {
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
