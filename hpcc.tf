module "hpcc" {
  source = "../../opinionated/opinionated-terraform-azurerm-hpcc"

  count = var.hpcc_enabled ? 1 : 0

  environment = var.metadata.environment
  productname = var.metadata.product_name

  internal_domain = var.internal_domain
  cluster_name    = local.get_kubeconfig_data.cluster_name

  hpcc_container = {
    image_name           = var.hpcc_container != null ? var.hpcc_container.image_name : null
    image_root           = var.hpcc_container != null ? var.hpcc_container.image_root : null
    version              = var.hpcc_container != null ? var.hpcc_container.version : null
    custom_chart_version = var.hpcc_container != null ? var.hpcc_container.custom_chart_version : null
    custom_image_version = var.hpcc_container != null ? var.hpcc_container.custom_image_version : null
  }

  hpcc_container_registry_auth = var.hpcc_container_registry_auth != null ? {
    password = var.hpcc_container_registry_auth.password
    username = var.hpcc_container_registry_auth.username
  } : null

  enable_node_tuning      = false //Disable CSI driver
  install_blob_csi_driver = false //Disable CSI driver

  node_tuning_containers = var.node_tuning.containers

  node_tuning_container_registry_auth = var.node_tuning_container_registry_auth

  resource_group_name = local.get_kubeconfig_data.resource_group_name
  location            = var.metadata.location
  tags                = module.metadata.tags

  namespace = var.hpcc_namespace

  admin_services_storage_account_settings = {
    replication_type     = var.admin_services_storage_account_settings.replication_type
    authorized_ip_ranges = merge(var.admin_services_storage_account_settings.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body })
    delete_protection    = var.admin_services_storage_account_settings.delete_protection
    subnet_ids           = merge({ aks = local.subnet_ids.aks })
  }

  data_storage_config = {
    internal = {
      blob_nfs = {
        data_plane_count = var.data_storage_config.internal.blob_nfs.data_plane_count
        storage_account_settings = {
          replication_type     = var.data_storage_config.internal.blob_nfs.storage_account_settings.replication_type
          authorized_ip_ranges = merge(var.admin_services_storage_account_settings.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body })
          delete_protection    = var.data_storage_config.internal.blob_nfs.storage_account_settings.delete_protection
          subnet_ids           = merge({ aks = local.subnet_ids.aks })
        }
      }

      # hpc_cache = var.data_storage_config.internal.hpc_cache.enabled ? {
      #   dns = {
      #     zone_name                = var.internal_domain
      #     zone_resource_group_name = var.dns_resource_group
      #   }

      #   resource_provider_object_id = var.azuread_clusterrole_map.cluster_admin_user.user_object_id
      #   size                        = var.data_storage_config.internal.hpc_cache.size
      #   cache_update_frequency      = var.data_storage_config.internal.hpc_cache.cache_update_frequency
      #   storage_account_data_planes = var.data_storage_config.internal.hpc_cache.storage_account_data_planes
      #   # subnet_id                   = try(local.subnet_ids.hpc_cache, module.virtual_network[0].subnets.hpc_cache.id)
      #   subnet_id = local.virtual_network.hpc_cache
      # } : null
    }

    external = var.data_storage_config.external
  }

  spill_volumes = var.spill_volumes

  roxie_config = var.roxie_config

  thor_config = var.thor_config

  vault_config = var.vault_config

  eclccserver_settings = var.eclccserver_settings

  spray_service_settings = var.spray_service_settings

  admin_services_node_selector = { all = { workload = var.spray_service_settings.nodeSelector } }

  log_access_role_assignment = {
    scope     = var.azure_log_analytics_creds.scope
    object_id = var.azure_log_analytics_creds.object_id
  }

  esp_remoteclients = {

    "sample-remoteclient" = {

      name = "sample-remoteclient"

      labels = {

        "test" = "client"

      }

    }

  }

  helm_chart_files_overrides = var.helm_chart_files_overrides

  ldap_config = var.ldap
}
