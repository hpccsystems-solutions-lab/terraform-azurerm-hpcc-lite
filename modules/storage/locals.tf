locals {
  get_vnet_config = fileexists("../vnet/data/config.json") ? jsondecode(file("../vnet/data/config.json")) : null
  # get_aks_config  = fileexists("../aks/data/config.json") ? jsondecode(file("../aks/data/config.json")) : null

  virtual_network = var.virtual_network != null ? var.virtual_network : {
    name                = local.get_vnet_config.name
    resource_group_name = local.get_vnet_config.resource_group_name
    location            = local.get_vnet_config.location
    subnet_ids          = { aks = local.get_vnet_config.private_subnet_name }
  }
}
