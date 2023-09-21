data "azurerm_advisor_recommendations" "advisor" {

  filter_by_category        = ["security", "cost"]
  filter_by_resource_groups = [module.resource_groups["virtual_network"].name]
}

data "http" "host_ip" {
  url = "https://api.ipify.org"
}

data "azurerm_subscription" "current" {
}
