output "advisor_recommendations" {
  description = "Advisor recommendations or 'none'"
  value = data.azurerm_advisor_recommendations.advisor.recommendations == tolist([])? "none" : data.azurerm_advisor_recommendations.advisor.recommendations
}
output "aks_login" {
  description = "Location of the aks credentials"
  value = "az aks get-credentials --name ${module.aks.cluster_name} --resource-group ${module.resource_groups["azure_kubernetes_service"].name}"
}

output "cluster_name" {
  description = "Name of the Azure Kubernetes Service"
  value       = module.aks.cluster_name
}

output "cluster_resource_group_name" {
  description = "Resource group where the cluster is deployed"
  value       = module.resource_groups["azure_kubernetes_service"].name
}

resource "local_file" "output" {
  content  = local.config
  filename = "${path.module}/data/config.json"

  depends_on = [ module.aks ]
}
