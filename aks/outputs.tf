output "advisor_recommendations" {
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}
output "aks_login" {
  value = "az aks get-credentials --name ${module.aks.cluster_name} --resource-group ${module.resource_groups["azure_kubernetes_service"].name}"
}

output "cluster_name" {
  description = "The name of the Azure Kubernetes Service."
  value       = module.aks.cluster_name
}

output "hpcc_log_analytics_enabled" {
  description = "Is Log Analytics enabled for HPCC?"
  value       = var.hpcc_log_analytics_enabled && fileexists("../logging/data/workspace_resource_id.txt")
}

output "cluster_resource_group_name" {
  description = "The resource group where the cluster is deployed."
  value       = module.resource_groups["azure_kubernetes_service"].name
}

resource "local_file" "output" {
  content  = local.config
  filename = "${path.module}/data/config.json"

  depends_on = [ module.aks ]
}
