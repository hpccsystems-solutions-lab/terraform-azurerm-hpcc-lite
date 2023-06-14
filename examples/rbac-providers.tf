provider "azurerm" {
  tenant_id       = var.azure_auth.AAD_TENANT_ID
  subscription_id = var.azure_auth.SUBSCRIPTION_ID
  client_id       = var.azure_auth.AAD_CLIENT_ID
  client_secret   = var.azure_auth.AAD_CLIENT_SECRET

  features {}
}

provider "kubernetes" {
  host                   = module.kubernetes.kube_config.host
  cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = ["get-token", "--login", "spn", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630", "--environment", "AzurePublicCloud", "--tenant-id", var.azure_auth.AAD_TENANT_ID, "--client-id", var.azure_auth.AAD_CLIENT_ID, "--client-secret", var.azure_auth.AAD_CLIENT_SECRET]
  }
}

provider "kubectl" {
  host                   = module.kubernetes.kube_config.host
  cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)
  load_config_file       = false
  apply_retry_count      = 6

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = ["get-token", "--login", "spn", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630", "--environment", "AzurePublicCloud", "--tenant-id", var.azure_auth.AAD_TENANT_ID, "--client-id", var.azure_auth.AAD_CLIENT_ID, "--client-secret", var.azure_auth.AAD_CLIENT_SECRET]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.kube_config.host
    cluster_ca_certificate = base64decode(module.kubernetes.kube_config.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = ["get-token", "--login", "spn", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630", "--environment", "AzurePublicCloud", "--tenant-id", var.azure_auth.AAD_TENANT_ID, "--client-id", var.azure_auth.AAD_CLIENT_ID, "--client-secret", var.azure_auth.AAD_CLIENT_SECRET]
    }
  }

  experiments {
    manifest = true
  }
}

