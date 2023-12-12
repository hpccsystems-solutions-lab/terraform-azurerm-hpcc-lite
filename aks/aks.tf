module "aks" {
  depends_on = [random_string.string]
  #source     = "git@github.com:hpccsystems-solutions-lab/tlh-oss-terraform-azurerm-aks.git"
  source     = "https://github.com/hpccsystems-solutions-lab/tlh-oss-terraform-azurerm-aks.git"
  #source     = "/home/azureuser/temp/OSS/terraform-azurerm-aks"

  providers = {
    kubernetes = kubernetes.default
    helm       = helm.default
    kubectl    = kubectl.default
  }

  location            = local.metadata.location
  resource_group_name = module.resource_groups["azure_kubernetes_service"].name

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  # for v1.6.2 aks: network_plugin  = "kubenet"
  # for v1.6.2 aks: sku_tier_paid   = false
  sku_tier = var.sku_tier

  logging_monitoring_enabled = var.aks_logging_monitoring_enabled

  cluster_endpoint_access_cidrs = var.cluster_endpoint_access_cidrs

  virtual_network_resource_group_name = try(var.use_existing_vnet.resource_group_name, local.get_vnet_config.resource_group_name)
  virtual_network_name                = try(var.use_existing_vnet.name, local.get_vnet_config.name)
  subnet_name                         = try(var.use_existing_vnet.subnets.aks.name, "aks-hpcc-private")
  route_table_name                    = try(var.use_existing_vnet.route_table_name, local.get_vnet_config.route_table_name)

  dns_resource_group_lookup = { "${local.internal_domain}" = local.dns_resource_group }

  admin_group_object_ids = [data.azuread_group.subscription_owner.object_id]

  rbac_bindings = var.rbac_bindings

  availability_zones = var.availability_zones
  node_groups        = local.node_groups

  core_services_config = {
    alertmanager = local.core_services_config.alertmanager
    coredns      = local.core_services_config.coredns
    external_dns = local.core_services_config.external_dns
    cert_manager = local.core_services_config.cert_manager

    ingress_internal_core = {
      domain           = local.core_services_config.ingress_internal_core.domain
      subdomain_suffix = "${local.core_services_config.ingress_internal_core.subdomain_suffix}${trimspace(local.owner_name_initials)}" // dns record suffix
      public_dns       = local.core_services_config.ingress_internal_core.public_dns
    }
  }

  tags = local.tags

  storage = {
    file = { enabled = true }
    blob = { enabled = true }
  }

  logging = var.logging
}
