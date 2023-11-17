data "http" "host_ip" {
  url = "https://api.ipify.org"
}

data "azurerm_subscription" "current" {
}

data "azuread_group" "subscription_owner" {
  display_name = "ris-azr-group-${data.azurerm_subscription.current.display_name}-owner"
}

data "azurerm_client_config" "current" {
}

data "local_file" "aks" {
  filename = "../aks/data/config.json"
}

