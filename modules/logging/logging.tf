module "logging" {
  source = "github.com/gfortil/terraform-azurerm-hpcc-logging.git?ref=HPCC-29420"

  azure_log_analytics_workspace = var.azure_log_analytics_workspace != null ? {
    unique_name                        = true
    daily_quota_gb                     = var.azure_log_analytics_workspace.daily_quota_gb
    internet_ingestion_enabled         = var.azure_log_analytics_workspace.internet_ingestion_enabled
    internet_query_enabled             = var.azure_log_analytics_workspace.internet_query_enabled
    location                           = var.location
    name                               = var.azure_log_analytics_workspace.name
    resource_group_name                = module.resource_group.name
    reservation_capacity_in_gb_per_day = var.azure_log_analytics_workspace.reservation_capacity_in_gb_per_day
    retention_in_days                  = var.azure_log_analytics_workspace.retention_in_days
    sku                                = var.azure_log_analytics_workspace.sku
    use_existing_workspace             = var.azure_log_analytics_workspace.use_existing_workspace
    tags                               = merge(local.tags, var.azure_log_analytics_workspace.tags)
  } : null

  // Should be set as an environment variable or stored in a key vault
  azure_log_analytics_creds = var.azure_log_analytics_creds

  hpcc = {
    namespace = local.hpcc_namespace
    version   = var.hpcc.version
  }

  elastic4hpcclogs = var.azure_log_analytics_workspace == null ? {
    internet_enabled           = var.elastic4hpcclogs.internet_enabled
    name                       = var.elastic4hpcclogs.name
    atomic                     = var.elastic4hpcclogs.atomic
    recreate_pods              = var.elastic4hpcclogs.recreate_pods
    reuse_values               = var.elastic4hpcclogs.reuse_values
    reset_values               = var.elastic4hpcclogs.reset_values
    force_update               = var.elastic4hpcclogs.force_update
    cleanup_on_fail            = var.elastic4hpcclogs.cleanup_on_fail
    disable_openapi_validation = var.elastic4hpcclogs.disable_openapi_validation
    max_history                = var.elastic4hpcclogs.max_history
    wait                       = var.elastic4hpcclogs.wait
    dependency_update          = var.elastic4hpcclogs.dependency_update
    timeout                    = var.elastic4hpcclogs.timeout
    wait_for_jobs              = var.elastic4hpcclogs.wait_for_jobs
    lint                       = var.elastic4hpcclogs.lint
    remote_chart               = var.elastic4hpcclogs.remote_chart
    local_chart                = var.elastic4hpcclogs.local_chart
    version                    = var.elastic4hpcclogs.version
  } : null
}
