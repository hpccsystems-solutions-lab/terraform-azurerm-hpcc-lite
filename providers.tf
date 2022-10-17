# provider "azurerm" {
#   features {}
# }

# provider "kubernetes" {
#   host                   = module.kubernetes.kube_config.host
#   client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
#   client_key             = base64decode(module.kubernetes.kube_config.client_key)
#   cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.kubernetes.kube_config.host
#     client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
#     client_key             = base64decode(module.kubernetes.kube_config.client_key)
#     cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
#   }
# }

# provider "kubectl" {
#   host                   = module.kubernetes.kube_config.host
#   client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
#   client_key             = base64decode(module.kubernetes.kube_config.client_key)
#   cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
#   load_config_file       = false
#   apply_retry_count      = 6
# }

#######
############ Comment above providers and uncomment the providers below to use RBAC
#######
provider "azurerm" {
  tenant_id       = var.azure_auth.AAD_TENANT_ID
  subscription_id = var.azure_auth.SUBSCRIPTION_ID
  client_id       = var.azure_auth.AAD_CLIENT_ID
  client_secret   = var.azure_auth.AAD_CLIENT_SECRET

  features {}
}

provider "kubernetes" {
  host                   = module.kubernetes.kube_config.host
  client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)

  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "kubelogin"
  #   args        = ["get-token", "--login", "spn", "--server-id", var.azure_auth.AAD_SERVER_APP_ID, "--environment", "AzurePublicCloud", "--tenant-id", var.azure_auth.AAD_TENANT_ID]
  #   env         = local.kubelogin_exec_env
  # }
}

provider "kubectl" {
  host                   = module.kubernetes.kube_config.host
  client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
  load_config_file       = false
  apply_retry_count      = 6

  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "kubelogin"
  #   args        = ["get-token", "--server-id", var.azure_auth.AAD_SERVER_APP_ID, "--login", "azurecli", "--tenant-id", var.azure_auth.AAD_TENANT_ID]
  #   env         = local.kubelogin_exec_env
  # }
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.kube_config.host
    client_certificate     = base64decode(module.kubernetes.kube_config.client_certificate)
    client_key             = base64decode(module.kubernetes.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)

    # exec {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   command     = "kubelogin"
    #   args        = ["get-token", "--login", "spn", "--server-id", var.azure_auth.AAD_SERVER_APP_ID, "--environment", "AzurePublicCloud", "--tenant-id", var.azure_auth.AAD_TENANT_ID]
    #   env         = local.kubelogin_exec_env
    # }
  }

  experiments {
    manifest = true
  }
}
