resource "helm_release" "storage" {
  name                       = "azstorage"
  chart                      = can(var.storage.remote_chart) ? "hpcc-azurefile" : var.storage.local_chart
  repository                 = can(var.storage.remote_chart) ? var.storage.remote_chart : null
  version                    = can(var.storage.version) ? var.storage.version : null
  values                     = concat(var.storage.default ? [] : [local.hpcc_azurefile], try([for v in var.storage.values : file(v)], []))
  create_namespace           = true
  namespace                  = try(var.hpcc.namespace, terraform.workspace)
  atomic                     = try(var.storage.atomic, false)
  force_update               = try(var.storage.force_update, false)
  recreate_pods              = try(var.storage.recreate_pods, false)
  reuse_values               = try(var.storage.reuse_values, false)
  reset_values               = try(var.storage.reset_values, false)
  cleanup_on_fail            = try(var.storage.cleanup_on_fail, null)
  disable_openapi_validation = try(var.storage.disable_openapi_validation, false)
  wait                       = try(var.storage.wait, true)
  max_history                = try(var.storage.max_history, 0)
  dependency_update          = try(var.storage.dependency_update, false)
  timeout                    = try(var.storage.timeout, 600)
  wait_for_jobs              = try(var.storage.wait_for_jobs, false)
  lint                       = try(var.storage.lint, false)

  depends_on = [
    module.kubernetes
  ]
}

module "hpcc" {
  source = "../terraform-azurerm-hpcc-preview"

  hpcc = {
    default_storage      = var.hpcc.default_storage
    tls_enabled          = var.hpcc.tls_enabled
    internet_enabled     = var.hpcc.internet_enabled
    auto_connect         = var.hpcc.auto_connect
    auto_launch_eclwatch = var.hpcc.auto_launch_eclwatch
  }

  #   cert_manager                   = var.hpcc.tls_enabled == true ? var.cert_manager : null
  registry = var.registry
  #   internal_domain                = var.internal_domain
  #   tls_crt                        = file(var.tls_crt_src)
  #   tls_key                        = file(var.tls_key_src)
  admin                          = var.admin
  kubernetes_name                = module.kubernetes.name
  kubernetes_resource_group_name = module.resource_group.name
  #   labels                         = var.labels
  #   dns_resource_group_lookup      = var.dns_resource_group_lookup
  subscription_id = module.subscription.output.subscription_id
  #   azure_environment              = var.azure_environment
  #   zerossl_kid                    = var.zerossl_kid
  #   zerossl_eabsecret              = var.zerossl_eabsecret
  tags = var.tags

  aks_automation = {
    automation_account_name = var.metadata.project
    # local_authentication_enabled  = false
    # public_network_access_enabled = false
    resource_group_name = module.resource_group.name

    schedule = [
      {
        schedule_name   = "aks_stop"
        description     = var.aks_automation.schedule[0].description
        frequency       = var.aks_automation.schedule[0].frequency
        interval        = var.aks_automation.schedule[0].frequency == "OneTime" ? null : var.aks_automation.schedule[0].interval
        start_time      = var.aks_automation.schedule[0].start_time
        week_days       = var.aks_automation.schedule[0].week_days
        operation       = "stop"
        cluster_name    = module.kubernetes.name
        daylight_saving = var.aks_automation.schedule[0].daylight_saving
      },
      {
        schedule_name   = "aks_start"
        description     = var.aks_automation.schedule[1].description
        frequency       = var.aks_automation.schedule[1].frequency
        interval        = var.aks_automation.schedule[1].frequency == "OneTime" ? null : var.aks_automation.schedule[1].interval
        start_time      = var.aks_automation.schedule[1].start_time
        week_days       = var.aks_automation.schedule[1].week_days
        operation       = "start"
        cluster_name    = module.kubernetes.name
        daylight_saving = var.aks_automation.schedule[1].daylight_saving
      }
    ]
  }
}
