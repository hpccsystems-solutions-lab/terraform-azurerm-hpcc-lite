output "advisor_recommendations" {
  value = data.azurerm_advisor_recommendations.advisor.recommendations
}
output "aks_login" {
  value = "az aks get-credentials --name ${module.aks.cluster_name} --resource-group ${module.resource_groups["azure_kubernetes_service"].name}"
}

resource "local_file" "output" {
  content  = local.kubeconfig
  filename = "${path.module}/bin/kubeconfig.json"
}