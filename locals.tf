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

  tags = var.disable_naming_conventions ? merge(
    var.tags,
    {
      "owner"       = var.owner.name,
      "owner_email" = var.owner.email
    }
    ) : merge(
    module.metadata.tags,
    {
      "owner"       = var.owner.name,
      "owner_email" = var.owner.email
    },
    try(var.tags)
  )

  get_vnet_data       = fileexists("${path.module}/modules/virtual_network/bin/vnet.json") ? jsondecode(file("${path.module}/modules/virtual_network/bin/vnet.json")) : null
  get_kubeconfig_data = fileexists("${path.module}/modules/aks/bin/kubeconfig.json") ? jsondecode(file("${path.module}/modules/aks/bin/kubeconfig.json")) : null


  subnet_ids = try({
    for k, v in var.use_existing_vnet.subnets : k => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.use_existing_vnet.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.use_existing_vnet.name}/subnets/${v.name}"
  }, { aks = local.get_vnet_data.private_subnet_id })

  location = var.use_existing_vnet != null ? var.use_existing_vnet.location : local.get_vnet_data.location

  # hpcc_chart_major_minor_point_version = var.helm_chart_version != null ? regex("[\\d+?.\\d+?.\\d+?]+", var.helm_chart_version) : "master"

  domain = coalesce(var.internal_domain, format("us-%s.%s.azure.lnrsg.io", "var.metadata.product_name", "dev"))

  hpcc_namespace = var.hpcc_namespace != null ? var.hpcc_namespace : {
    name = "hpcc-${var.owner.name}-${random_integer.int.result}"
    labels = {
      name = "hpcc-${var.owner.name}-${random_integer.int.result}"
    }
  }

  web_urls      = { auto_launch_eclwatch = "https://eclwatch-${var.hpcc_namespace.name}.${local.domain}" }
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
