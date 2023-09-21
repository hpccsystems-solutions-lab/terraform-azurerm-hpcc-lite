locals {
  azure_auth_env = {
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
  }

  names = var.disable_naming_conventions ? merge(
    {
      business_unit     = var.metadata.business_unit
      environment       = var.metadata.environment
      location          = var.metadata.location
      market            = var.metadata.market
      subscription_type = var.metadata.subscription_type
    },
    var.metadata.product_group != "" ? { product_group = var.metadata.product_group } : {},
    var.metadata.product_name != "" ? { product_name = var.metadata.product_name } : {},
    var.metadata.resource_group_type != "" ? { resource_group_type = var.metadata.resource_group_type } : {}
  ) : module.metadata.names

  tags = merge(var.metadata.additional_tags, { "owner" = var.owner.name, "owner_email" = var.owner.email })

  # external_services_storage_exists = fileexists("../storage/data/config.json") || var.external_services_storage_config != null

  get_vnet_config    = fileexists("../vnet/data/config.json") ? jsondecode(file("../vnet/data/config.json")) : null
  get_aks_config     = fileexists("../aks/data/config.json") ? jsondecode(file("../aks/data/config.json")) : null
  get_storage_config = local.external_storage_exists ? jsondecode(file("../storage/data/config.json")) : null

  external_storage_exists = fileexists("../storage/data/config.json") || var.external_storage_config != null

  subnet_ids = try({
    for k, v in var.use_existing_vnet.subnets : k => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.use_existing_vnet.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.use_existing_vnet.name}/subnets/${v.name}"
  }, { aks = local.get_vnet_config.private_subnet_id })

  location = var.use_existing_vnet != null ? var.use_existing_vnet.location : local.get_vnet_config.location

  # hpcc_chart_major_minor_point_version = var.helm_chart_version != null ? regex("[\\d+?.\\d+?.\\d+?]+", var.helm_chart_version) : "master"

  domain = coalesce(var.internal_domain, format("us-%s.%s.azure.lnrsg.io", "var.metadata.product_name", "dev"))

  internal_storage_enabled = (local.external_storage_exists == true) && (var.ignore_external_storage == true) ? true : local.external_storage_exists == true && var.ignore_external_storage == false ? false : true
  # external_services_storage_enabled = local.external_services_storage_exists == true && var.ignore_external_services_storage == false ? true : local.external_services_storage_exists == true && var.ignore_external_services_storage == true ? false : true

  hpcc_namespace = var.hpcc_namespace.existing_namespace != null ? var.hpcc_namespace.existing_namespace : var.hpcc_namespace.create_namespace == true ? kubernetes_namespace.hpcc[0].metadata[0].name : fileexists("${path.module}/logging/data/hpcc_namespace.txt") ? file("${path.module}/logging/data/hpcc_namespace.txt") : "default"

  external_storage_config = local.get_storage_config != null && var.ignore_external_storage == false ? [
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

  svc_domains   = { eclwatch = var.auto_launch_svc.eclwatch ? "https://eclwatch-${local.hpcc_namespace}.${local.domain}:18010" : null }
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
