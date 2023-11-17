output "advisor_recommendations" {
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}

output "private_subnet_id" {
  value = module.virtual_network.aks.hpcc.subnets["private"].id
}

output "public_subnet_id" {
  value = module.virtual_network.aks.hpcc.subnets["public"].id
}

output "route_table_id" {
  value = module.virtual_network.aks.hpcc.route_table_id
}

output "route_table_name" {
  value = "${module.virtual_network.vnet.resource_group_name}-aks-hpcc-routetable"
}

output "resource_group_name" {
  value = module.virtual_network.vnet.resource_group_name
}

output "vnet_name" {
  value = module.virtual_network.vnet.name
}

resource "local_file" "output" {
  content  = local.config
  filename = "${path.module}/data/config.json"

  depends_on = [ module.virtual_network ]
}


