provider "azurerm" {
  features {}
  use_cli             = true
  storage_use_azuread = true
}

provider "azuread" {}

# provider "kubernetes" {
#   host                   = local.get_aks_config.kube_admin_config[0].host
#   client_certificate     = base64decode(local.get_aks_config.kube_admin_config[0].client_certificate)
#   client_key             = base64decode(local.get_aks_config.kube_admin_config[0].client_key)
#   cluster_ca_certificate = base64decode(local.get_aks_config.kube_admin_config[0].cluster_ca_certificate)
# }