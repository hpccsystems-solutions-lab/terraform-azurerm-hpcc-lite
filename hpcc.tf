resource "kubernetes_namespace" "hpcc" {
  count = var.hpcc_namespace.create_namespace && !fileexists("${path.module}/modules/logging/data/hpcc_namespace.txt") ? 1 : 0

  metadata {
    labels = try(var.hpcc_namespace.labels,{})

    generate_name = "${var.hpcc_namespace.prefix_name}${trimspace(local.owner.name)}"
  }
}

/*resource "kubernetes_namespace" "hpcc" {
  count = (var.hpcc_namespace == []) || !var.hpcc_namespace.create_namespace || fileexists("${path.module}/modules/logging/data/hpcc_namespace.txt") ? 0 : 1

  metadata {
    labels = try(var.hpcc_namespace.labels,{})
    name   = "${substr(trimspace(local.owner.name), 0, 5)}${random_integer.random.result}"
    # generate_name = "${trimspace(local.owner.name)}"
  }
}*/

module "hpcc" {
  #source = "git@github.com:gfortil/opinionated-terraform-azurerm-hpcc?ref=HPCC-27615"
  source = "/home/azureuser/godji/opinionated-terraform-azurerm-hpcc"

  environment = local.metadata.environment
  productname = local.metadata.product_name

  internal_domain = local.internal_domain
  cluster_name    = local.get_aks_config.cluster_name

  hpcc_container = {
    image_name           = local.hpcc_container != null ? local.hpcc_container.image_name : null
    image_root           = local.hpcc_container != null ? local.hpcc_container.image_root : null
    version              = local.hpcc_container != null ? local.hpcc_container.version : null
    custom_chart_version = local.hpcc_container != null ? local.hpcc_container.custom_chart_version : null
    custom_image_version = local.hpcc_container != null ? local.hpcc_container.custom_image_version : null
  }

  hpcc_container_registry_auth = local.hpcc_container_registry_auth != null ? {
    password = local.hpcc_container_registry_auth.password
    username = local.hpcc_container_registry_auth.username
  } : null

  install_blob_csi_driver = false //Disable CSI driver

  resource_group_name = local.get_aks_config.resource_group_name
  location            = local.metadata.location
  tags                = module.metadata.tags

  # namespace = local.hpcc_namespace
  namespace = {
    create_namespace = false
    name             = local.hpcc_namespace
    labels           = try(var.hpcc_namespace.labels,{})
  }

  admin_services_storage_account_settings = {
    replication_type     = local.admin_services_storage_account_settings.replication_type
    authorized_ip_ranges = merge(local.admin_services_storage_account_settings.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body })
    delete_protection    = local.admin_services_storage_account_settings.delete_protection
    subnet_ids           = merge({ aks = local.subnet_ids.aks })
  }

  data_storage_config = {
    internal = {
      blob_nfs = {
        data_plane_count = local.data_storage_config.internal.blob_nfs.data_plane_count
        storage_account_settings = {
          replication_type     = local.data_storage_config.internal.blob_nfs.storage_account_settings.replication_type
          authorized_ip_ranges = merge(local.admin_services_storage_account_settings.authorized_ip_ranges, { host_ip = data.http.host_ip.response_body })
          delete_protection    = local.data_storage_config.internal.blob_nfs.storage_account_settings.delete_protection
          subnet_ids           = merge({ aks = local.subnet_ids.aks })
        }
      }
    } 

    # external = local.internal_data_storage_enabled ? null : {
    #   blob_nfs = local.get_storage_config != null ? local.get_storage_config.data_storage_planes : local.data_storage_config.external.blob_nfs
    #   hpcc     = null
    # }
    external = null
  }

  #external_storage_config = local.external_storage_config

  spill_volumes                = local.spill_volumes
  roxie_config                 = local.roxie_config
  thor_config                  = local.thor_config
  vault_config                 = local.vault_config
  eclccserver_settings         = local.eclccserver_settings
  spray_service_settings       = local.spray_service_settings
  admin_services_node_selector = { all = { workload = local.spray_service_settings.nodeSelector } }

  esp_remoteclients = {

    "sample-remoteclient" = {

      name = "sample-remoteclient"

      labels = {

        "test" = "client"

      }

    }

  }

  helm_chart_timeout         = local.helm_chart_timeout
  helm_chart_files_overrides = concat(local.helm_chart_files_overrides, fileexists("${path.module}/modules/logging/data/logaccess_body.yaml") ? ["${path.module}/modules/logging/data/logaccess_body.yaml"] : [])
  ldap_config                = local.ldap_config
}
