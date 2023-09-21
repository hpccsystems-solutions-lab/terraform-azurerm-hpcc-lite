# resource "kubernetes_secret" "private_docker_registry" {
#   count = can(var.registry.server) && can(var.registry.username) && can(var.registry.password) ? 1 : 0
#   metadata {
#     name = "docker-cfg"
#   }
#   type = "kubernetes.io/dockerconfigjson"
#   data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "${var.registry.server}" = {
#           "username" = var.registry.username
#           "password" = var.registry.password
#           "email"    = var.admin.email
#           "auth"     = base64encode("${var.registry.username}:${var.registry.password}")
#         }
#       }
#     })
#   }
# }

module "aks" {
  depends_on = [random_string.string]
  #source     = "github.com/gfortil/terraform-azurerm-aks.git?ref=HPCC-27615"
  source     = "git@github.com:gfortil/terraform-azurerm-aks.git?ref=HPCC-27615"

  providers = {
    kubernetes = kubernetes.default
    helm       = helm.default
    kubectl    = kubectl.default
  }

  location            = var.metadata.location
  resource_group_name = module.resource_groups["azure_kubernetes_service"].name

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  # for v1.6.2 aks: network_plugin  = "kubenet"
  # for v1.6.2 aks: sku_tier_paid   = false
  sku_tier = var.sku_tier

  cluster_endpoint_access_cidrs = var.cluster_endpoint_access_cidrs

  virtual_network_resource_group_name = try(var.use_existing_vnet.resource_group_name, local.get_vnet_config.resource_group_name)
  virtual_network_name                = try(var.use_existing_vnet.name, local.get_vnet_config.name)
  subnet_name                         = try(var.use_existing_vnet.subnets.aks.name, "aks-hpcc-private")
  route_table_name                    = try(var.use_existing_vnet.route_table_name, local.get_vnet_config.route_table_name)

  dns_resource_group_lookup = { "${var.internal_domain}" = var.dns_resource_group }

  admin_group_object_ids = [data.azuread_group.subscription_owner.object_id]

  rbac_bindings = var.rbac_bindings

  availability_zones = var.availability_zones
  node_groups        = var.node_groups

  core_services_config = {
    alertmanager = var.core_services_config.alertmanager
    coredns      = var.core_services_config.coredns
    external_dns = var.core_services_config.external_dns
    cert_manager = var.core_services_config.cert_manager

    ingress_internal_core = {
      domain           = var.core_services_config.ingress_internal_core.domain
      subdomain_suffix = "${var.core_services_config.ingress_internal_core.subdomain_suffix}${trimspace(var.owner.name)}" // dns record suffix
      public_dns       = var.core_services_config.ingress_internal_core.public_dns
    }
  }

  tags = local.tags

  storage = {
    file = { enabled = true }
    blob = { enabled = true }
  }

  logging = var.logging

  experimental = {
    oms_agent                            = var.hpcc_log_analytics_enabled || var.experimental.oms_agent
    oms_agent_log_analytics_workspace_id = fileexists("../logging/data/workspace_resource_id.txt") ? file("../logging/data/workspace_resource_id.txt") : var.experimental.oms_agent_log_analytics_workspace_id != null ? var.experimental.oms_agent_log_analytics_workspace_id : null
  }
}
