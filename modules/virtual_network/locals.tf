locals {
  resource_groups = {
    for k, v in var.resource_groups : k => v
  }

  names = var.disable_naming_conventions ? merge(
    {
      business_unit     = var.metadata.business_unit
      environment       = var.metadata.environment
      location          = var.resource_groups.location
      market            = var.metadata.market
      subscription_type = var.metadata.subscription_type
    },
    var.metadata.product_group != "" ? { product_group = var.metadata.product_group } : {},
    var.metadata.product_name != "" ? { product_name = var.metadata.product_name } : {},
    var.metadata.resource_group_type != "" ? { resource_group_type = var.metadata.resource_group_type } : {}
  ) : module.metadata.names

  tags = var.disable_naming_conventions ? merge(var.tags, { "owner" = var.owner.name, "owner_email" = var.owner.email }, { "enclosed resource" = "vnet" }) : merge(module.metadata.tags, { "owner" = var.owner.name, "owner_email" = var.owner.email }, { "enclosed resource" = "vnet" }, try(var.tags))

  private_subnet_id   = module.virtual_network.aks.hpcc.subnets["private"].id
  public_subnet_id    = module.virtual_network.aks.hpcc.subnets["public"].id
  route_table_id      = module.virtual_network.aks.hpcc.route_table_id
  resource_group_name = module.virtual_network.vnet.resource_group_name
  name                = module.virtual_network.vnet.name


  vnet = jsonencode({
    "private_subnet_id" : "${local.private_subnet_id}",
    "private_subnet_name" : "aks-hpcc-private",
    "public_subnet_id" : "${local.public_subnet_id}",
    "public_subnet_name" : "aks-hpcc-public",
    "location" : "${module.resource_groups["virtual_network"].location}",
    "route_table_id" : "${local.route_table_id}",
    "route_table_name" : "${local.resource_group_name}-aks-hpcc-routetable",
    "resource_group_name" = "${local.resource_group_name}",
    "name"                = "${local.name}"
  })
}
