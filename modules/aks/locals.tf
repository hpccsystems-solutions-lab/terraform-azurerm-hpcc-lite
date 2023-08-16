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

  resource_groups = {
    for k, v in var.resource_groups : k => v
  }

  get_vnet_data = fileexists("../virtual_network/bin/vnet.json") ? jsondecode(file("../virtual_network/bin/vnet.json")) : null

  subnet_ids = try({
    for k, v in var.use_existing_vnet.subnets : k => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.use_existing_vnet.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.use_existing_vnet.name}/subnets/${v.name}"
  }, { aks = local.get_vnet_data.private_subnet_id })

  location = var.use_existing_vnet != null ? var.use_existing_vnet.location : local.get_vnet_data.location

  cluster_name = "tf-${terraform.workspace}-aks-${var.cluster_ordinal}"

  kubeconfig = jsonencode({
    "kube_admin_config" : "${module.aks.kube_admin_config}",
    "cluster_endpoint" : "${module.aks.cluster_endpoint}",
    "cluster_certificate_authority_data" : "${module.aks.cluster_certificate_authority_data}",
    "cluster_name" : "${module.aks.cluster_name}",
    "cluster_id" : "${module.aks.cluster_id}",
    "resource_group_name" : "${module.resource_groups["azure_kubernetes_service"].name}"
  })

  runbook      = { for rb in var.runbook : "${rb.runbook_name}" => rb }
  current_time = timestamp()
  current_day  = formatdate("EEEE", local.current_time)
  current_hour = tonumber(formatdate("HH", local.current_time))
  today        = formatdate("YYYY-MM-DD", local.current_time)
  tomorrow     = formatdate("YYYY-MM-DD", timeadd(local.current_time, "24h"))
  # today        = formatdate("YYYY-MM-DD", timeadd(local.current_time, "1h"))

  utc_offset = var.aks_automation.schedule[0].daylight_saving ? 4 : 5

  script   = { for item in fileset("${path.root}/scripts", "*") : (item) => file("${path.root}/scripts/${item}") }
  schedule = { for s in var.aks_automation.schedule : "${s.schedule_name}" => s }
}
