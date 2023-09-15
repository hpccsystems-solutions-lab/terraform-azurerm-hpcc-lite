provider "azurerm" {
  features {}
  use_cli             = true
  storage_use_azuread = true
}

provider "azuread" {}

provider "kubernetes" {
  host                   = local.get_aks_config.kube_admin_config[0].host
  client_certificate     = base64decode(local.get_aks_config.kube_admin_config[0].client_certificate)
  client_key             = base64decode(local.get_aks_config.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(local.get_aks_config.kube_admin_config[0].cluster_ca_certificate)
}

provider "kubectl" {
  host                   = local.get_aks_config.kube_admin_config[0].host
  client_key             = base64decode(local.get_aks_config.kube_admin_config[0].client_key)
  client_certificate     = base64decode(local.get_aks_config.kube_admin_config[0].client_certificate)
  cluster_ca_certificate = base64decode(local.get_aks_config.kube_admin_config[0].cluster_ca_certificate)

  load_config_file  = false
  apply_retry_count = 6

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = ["get-token", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630", "--login", "azurecli"]
    env         = local.azure_auth_env
  }
}


provider "helm" {
  kubernetes {
    host                   = local.get_aks_config.cluster_endpoint
    cluster_ca_certificate = base64decode(local.get_aks_config.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = ["get-token", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630", "--login", "azurecli"]
      env         = local.azure_auth_env
    }
  }

  experiments {
    manifest = true
  }
}

provider "shell" {
  sensitive_environment = local.azure_auth_env
}
