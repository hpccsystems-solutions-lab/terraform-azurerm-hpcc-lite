data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["Security", "Cost"]
  filter_by_resource_groups = [module.resource_groups["azure_kubernetes_service"].name]
}

data "http" "host_ip" {
  url = "https://api.ipify.org"
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}
