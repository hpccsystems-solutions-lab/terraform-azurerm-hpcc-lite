output "advisor_recommendations" {
  description = "Advisor recommendations or 'none'."
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}

output "private_subnet_id" {
  description = "ID of private subnet."
  value = module.virtual_network.aks.hpcc.subnets["private"].id
}

output "public_subnet_id" {
  description = "ID of public subnet."
  value = module.virtual_network.aks.hpcc.subnets["public"].id
}

output "route_table_id" {
  description = "ID of route table."
  value = module.virtual_network.aks.hpcc.route_table_id
}

output "route_table_name" {
  description = "Route table name."
  value = "${module.virtual_network.vnet.resource_group_name}-aks-hpcc-routetable"
}

output "resource_group_name" {
  description = "Virtual network resource group name."
  value = module.virtual_network.vnet.resource_group_name
}

output "vnet_name" {
  description = "Virtual network name."
  value = module.virtual_network.vnet.name
}

resource "local_file" "output" {
  content  = local.config
  filename = "${path.module}/data/config.json"

  depends_on = [ module.virtual_network ]
}
