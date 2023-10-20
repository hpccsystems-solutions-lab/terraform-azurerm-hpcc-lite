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

  resource_groups = {
    virtual_network = {
      tags = { "enclosed resource" = "open source vnet" }
    }
  }

  names = var.disable_naming_conventions ? merge(
    {
      business_unit     = local.metadata.business_unit
      environment       = local.metadata.environment
      location          = local.metadata.location
      market            = local.metadata.market
      subscription_type = local.metadata.subscription_type
    },
    local.metadata.product_group != "" ? { product_group = local.metadata.product_group } : {},
    local.metadata.product_name != "" ? { product_name = local.metadata.product_name } : {},
    local.metadata.resource_group_type != "" ? { resource_group_type = local.metadata.resource_group_type } : {}
  ) : module.metadata.names

  tags = merge(local.metadata.additional_tags, { "owner" = local.owner.name, "owner_email" = local.owner.email })


  private_subnet_id   = module.virtual_network.aks.hpcc.subnets["private"].id
  public_subnet_id    = module.virtual_network.aks.hpcc.subnets["public"].id
  route_table_id      = module.virtual_network.aks.hpcc.route_table_id
  resource_group_name = module.virtual_network.vnet.resource_group_name
  name                = module.virtual_network.vnet.name


  config = jsonencode({
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
