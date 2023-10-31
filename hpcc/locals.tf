locals {
  azure_auth_env = {
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
  }

  names = try(local.disable_naming_conventions, false) ? merge(
    {
      business_unit     = local.metadata.business_unit
      environment       = local.metadata.environment
      location          = local.metadata.location
      market            = local.metadata.market
      subscription_type = local.metadata.subscription_type
    },
    local.metadata.product_group != "" ? { product_group = local.metadata.product_group } : {},
    local.metadata.product_name != "" ? { product_name = local.metadata.product_name } : {},
    local.metadata.resource_group_type != "" ? { resource_group_type = local.metadata.resource_group_type } : {}
  ) : module.metadata.names

  # external_services_storage_exists = fileexists("../storage/data/config.json") || local.external_services_storage_config != null

  get_vnet_config    = fileexists("../vnet/data/config.json") ? jsondecode(file("../vnet/data/config.json")) : null
  get_aks_config     = fileexists("../aks/data/config.json") ? jsondecode(file("../aks/data/config.json")) : null
  get_storage_config = fileexists("../storage/data/config.json") ? jsondecode(file("../storage/data/config.json")) : null

  external_storage_exists = fileexists("../storage/data/config.json") || local.external_storage_config != null

  subnet_ids = try({
    for k, v in local.use_existing_vnet.subnets : k => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.use_existing_vnet.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.use_existing_vnet.name}/subnets/${v.name}"
  }, { aks = local.get_vnet_config.private_subnet_id })

  location = local.use_existing_vnet != null ? local.use_existing_vnet.location : local.get_vnet_config.location

  # hpcc_chart_major_minor_point_version = local.helm_chart_version != null ? regex("[\\d+?.\\d+?.\\d+?]+", local.helm_chart_version) : "master"

  domain = coalesce(local.internal_domain, format("us-%s.%s.azure.lnrsg.io", "local.metadata.product_name", "dev"))

  internal_storage_enabled = (local.external_storage_exists == true) && (var.external_storage_desired == false) ? true : local.external_storage_exists == true && var.external_storage_desired == true ? false : true
  #internal_storage_enabled = local.external_storage_exists == true && var.external_storage_desired == false ? true : local.external_storage_exists == true && var.external_storage_desired == true ? false : true
  # external_services_storage_enabled = local.external_services_storage_exists == true && local.external_storage_desired == true ? true : local.external_services_storage_exists == true && local.external_storage_desired == false ? false : true

  #hpcc_namespace = local.hpcc_namespace.existing_namespace != null ? local.hpcc_namespace.existing_namespace : local.hpcc_namespace.create_namespace == true ? kubernetes_namespace.hpcc[0].metadata[0].name : fileexists("../logging/data/hpcc_namespace.txt") ? file("../logging/data/hpcc_namespace.txt") : "default"
  hpcc_namespace = "default"

  external_storage_config = local.get_storage_config != null && var.external_storage_desired == true ? [
    for plane in local.get_storage_config.external_storage_config :
    {
      category        = plane.category
      container_name  = plane.container_name
      path            = plane.path
      plane_name      = plane.plane_name
      protocol        = plane.protocol
      resource_group  = plane.resource_group
      size            = plane.size
      storage_account = plane.storage_account
      storage_type    = plane.storage_type
      prefix_name     = plane.prefix_name
    }
  ] : []

  svc_domains   = { eclwatch = local.auto_launch_svc.eclwatch ? "https://eclwatch-${local.hpcc_namespace}.${local.domain}:18010" : null }
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
