resource "azurerm_dns_zone" "default" {
  count = var.cert_manager.enabled ? 1 : 0

  name                = external_dns.domain
  resource_group_name = module.resource_group.name
  soa_record {
    email         = var.admin.email
    host_name     = "ns1-03.azure-dns.com."
    expire_time   = 2419200
    minimum_ttl   = 300
    refresh_time  = 3600
    retry_time    = 300
    serial_number = 1
    ttl           = 3600
    tags          = { "associated_resource" = module.resource_group.name }
  }

  tags = { "associated_resource" = module.resource_group.name }
}

resource "helm_release" "nginx_ingress" {
  count = var.cert_manager.enabled ? 1 : 0

  name                       = "nginx-ingress"
  chart                      = "nginx/ingress-nginx"
  repository                 = "https://kubernetes.github.io/ingress-nginx"
  version                    = can(var.nginx_ingress.version) ? var.nginx_ingress.version : null
  values                     = concat(var.nginx_ingress.default ? [] : [local.hpcc_azurefile], try([for v in var.nginx_ingress.values : file(v)], []))
  create_namespace           = true
  namespace                  = local.namespaces.hpcc.metadata.name
  atomic                     = try(var.nginx_ingress.atomic, false)
  force_update               = try(var.nginx_ingress.force_update, false)
  recreate_pods              = try(var.nginx_ingress.recreate_pods, false)
  reuse_values               = try(var.nginx_ingress.reuse_values, false)
  reset_values               = try(var.nginx_ingress.reset_values, false)
  cleanup_on_fail            = try(var.nginx_ingress.cleanup_on_fail, null)
  disable_openapi_validation = try(var.nginx_ingress.disable_openapi_validation, false)
  wait                       = try(var.nginx_ingress.wait, true)
  max_history                = try(var.nginx_ingress.max_history, 0)
  dependency_update          = try(var.nginx_ingress.dependency_update, false)
  timeout                    = try(var.nginx_ingress.timeout, 600)
  wait_for_jobs              = try(var.nginx_ingress.wait_for_jobs, false)
  lint                       = try(var.nginx_ingress.lint, false)

  depends_on = [
    module.kubernetes
  ]
}

resource "azurerm_role_assignment" "dns_zone_contributor" {
  count = var.cert_manager.enabled ? 1 : 0

  scope                = azurerm_dns_zone.default.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = var.azure_auth.AAD_CLIENT_ID
}

resource "azurerm_role_assignment" "reader" {
  count = var.cert_manager.enabled ? 1 : 0

  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = var.azure_auth.AAD_CLIENT_ID
}

resource "helm_release" "external-dns" {
  count = var.cert_manager.enabled ? 1 : 0

  name                       = "external-dns"
  chart                      = "bitnami/external-dns"
  repository                 = "https://charts.bitnami.com/bitnami"
  version                    = can(var.external_dns.version) ? var.external_dns.version : null
  values                     = concat(var.external_dns.default ? [] : [local.hpcc_azurefile], try([for v in var.external_dns.values : file(v)], []))
  create_namespace           = true
  namespace                  = local.namespaces.hpcc.metadata.name
  atomic                     = try(var.external_dns.atomic, false)
  force_update               = try(var.external_dns.force_update, false)
  recreate_pods              = try(var.external_dns.recreate_pods, false)
  reuse_values               = try(var.external_dns.reuse_values, false)
  reset_values               = try(var.external_dns.reset_values, false)
  cleanup_on_fail            = try(var.external_dns.cleanup_on_fail, null)
  disable_openapi_validation = try(var.external_dns.disable_openapi_validation, false)
  wait                       = try(var.external_dns.wait, true)
  max_history                = try(var.external_dns.max_history, 0)
  dependency_update          = try(var.external_dns.dependency_update, false)
  timeout                    = try(var.external_dns.timeout, 600)
  wait_for_jobs              = try(var.external_dns.wait_for_jobs, false)
  lint                       = try(var.external_dns.lint, false)

  dynamic "set" {
    content {
      name  = "txtOwnerId"
      value = module.kubernetes.name
    }
  }

  dynamic "set" {
    content {
      name  = "provider"
      value = "azure"
    }
  }

  dynamic "set" {
    content {
      name  = "azure.resourceGroup"
      value = module.resource_group.name
    }
  }

  dynamic "set" {
    content {
      name  = "azure.tenantId"
      value = var.azure_auth.AAD_TENANT_ID
    }
  }

  dynamic "set" {
    content {
      name  = "azure.subscriptionId"
      value = data.azurerm_subscription.primary.id
    }
  }

  dynamic "set" {
    content {
      name  = "azure.aadClientId"
      value = var.azure_auth.AAD_CLIENT_ID
    }
  }

  dynamic "set" {
    content {
      name  = "azure.aadClientSecret"
      value = var.azure_auth.AAD_CLIENT_SECRET
    }
  }

  dynamic "set" {
    content {
      name  = "azure.cloud"
      value = "AzurePublicCloud"
    }
  }

  dynamic "set" {
    content {
      name  = "policy"
      value = "sync"
    }
  }

  dynamic "set" {
    content {
      name  = "domainFilters"
      value = var.external_dns.domain
    }
  }

  depends_on = [
    module.kubernetes,
    helm_release.nginx_ingress
  ]
}

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "externaldns"
    annotations = {
      "name"  = "external-dns"
      "admin" = var.admin.name
      "email" = var.admin.email
    }

    labels = {
      "app" = "external-dns"
    }
  }
}
