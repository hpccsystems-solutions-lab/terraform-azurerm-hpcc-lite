resource "random_string" "name" {
  length  = 3
  special = false
  numeric = false
  upper   = false
}

locals {
  roxiepool = {
    ultra_ssd         = false
    node_os           = "ubuntu"
    node_type         = "gp"
    node_type_version = "v2"
    node_size         = var.aks_roxie_node_size
    single_group      = false
    min_capacity      = 0
    max_capacity      = var.aks_nodepools_max_capacity
    labels = {
      "lnrs.io/tier" = "standard"
      "workload"     = "roxiepool"
    }
    taints = []
    tags   = {}
  }

  node_groups0 = {
    thorpool = {
      ultra_ssd         = false
      node_os           = "ubuntu"
      node_type         = "gp"      # gp, gpd, mem, memd, stor
      node_type_version = "v2"      # v1, v2
      node_size         = var.aks_thor_node_size
      single_group      = false
      min_capacity      = 0
      max_capacity      = var.aks_nodepools_max_capacity
      labels = {
        "lnrs.io/tier" = "standard"
        "workload"     = "thorpool"
      }
      taints = []
      tags   = {}
    },

    servpool = {
      ultra_ssd         = false
      node_os           = "ubuntu"
      node_type         = "gpd"
      node_type_version = "v1"
      node_size         = var.aks_serv_node_size
      single_group      = false
      min_capacity      = 3
      max_capacity      = var.aks_nodepools_max_capacity
      labels = {
        "lnrs.io/tier" = "standard"
        "workload"     = "servpool"
      }
      taints = []
      tags   = {}
    },

    spraypool = {
      ultra_ssd         = false
      node_os           = "ubuntu"
      node_type         = "gp"
      node_type_version = "v1"
      node_size         = var.aks_spray_node_size
      single_group      = false
      min_capacity      = 0
      max_capacity      = var.aks_nodepools_max_capacity
      labels = {
        "lnrs.io/tier"  = "standard"
        "workload"      = "spraypool"
        "spray-service" = "spraypool"
      }
      taints = []
      tags   = {}
    }
  }

  hpccpool = {
    ultra_ssd         = false
    node_os           = "ubuntu"
    node_type         = "gp"      # gp, gpd, mem, memd, stor
    node_type_version = "v2"      # v1, v2
    node_size         = var.aks_serv_node_size
    single_group      = false
    min_capacity      = 3
    max_capacity      = var.aks_nodepools_max_capacity
    labels = {
      "lnrs.io/tier" = "standard"
      "workload"     = "hpccpool"
    }
    taints = []
    tags   = {}
  }

  node_groups = var.aks_4nodepools? (var.aks_enable_roxie? merge( local.node_groups0, { roxiepool = local.roxiepool } ) : local.node_groups0) : { hpccpool = local.hpccpool }

  azure_auth_env = {
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
  }

  names = var.disable_naming_conventions ? merge(
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

  tags = { "owner" = local.owner.name, "owner_email" = local.owner.email }

  get_vnet_config = fileexists("../vnet/data/config.json") ? jsondecode(file("../vnet/data/config.json")) : null

  subnet_ids = try({
    for k, v in var.use_existing_vnet.subnets : k => "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.use_existing_vnet.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.use_existing_vnet.name}/subnets/${v.name}"
  }, { aks = local.get_vnet_config.private_subnet_id })

  location = var.use_existing_vnet != null ? var.use_existing_vnet.location : local.get_vnet_config.location

  cluster_name = "tf-${random_string.string.result}-${terraform.workspace}-aks-${var.cluster_ordinal}"

  config = jsonencode({
    "kube_admin_config" : "${module.aks.kube_admin_config}",
    "cluster_endpoint" : "${module.aks.cluster_endpoint}",
    "cluster_certificate_authority_data" : "${module.aks.cluster_certificate_authority_data}",
    "cluster_name" : "${module.aks.cluster_name}",
    "cluster_id" : "${module.aks.cluster_id}",
    "resource_group_name" : "${module.resource_groups["azure_kubernetes_service"].name}"
    "location" : "${local.location}"
  })

  runbook      = { for rb in var.runbook : "${rb.runbook_name}" => rb }
  current_time = timestamp()
  current_day  = formatdate("EEEE", local.current_time)
  current_hour = tonumber(formatdate("HH", local.current_time))
  today        = formatdate("YYYY-MM-DD", local.current_time)
  tomorrow     = formatdate("YYYY-MM-DD", timeadd(local.current_time, "24h"))

  script   = { for item in fileset("${path.root}/scripts", "*") : (item) => file("${path.root}/scripts/${item}") }

  az_command    = "az aks get-credentials --name ${local.cluster_name} --resource-group ${module.resource_groups["azure_kubernetes_service"].name}  --admin --overwrite-existing"
  is_windows_os = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
