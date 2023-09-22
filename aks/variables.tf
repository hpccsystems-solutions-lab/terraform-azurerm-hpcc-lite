variable "availability_zones" {
  description = "Availability zones to use for the node groups."
  type        = list(number)
  nullable    = false
  default     = [1]
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "owner" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })

  validation {
    condition = try(
      regex("hpccdemo", var.owner.name) != "hpccdemo", true
      ) && try(
      regex("hpccdemo", var.owner.email) != "hpccdemo", true
      ) && try(
      regex("@example.com", var.owner.email) != "@example.com", true
    )
    error_message = "Your name and email are required in the owner block and must not contain hpccdemo or @example.com."
  }
}

# variable "azure_auth" {
#   description = "Azure authentication"
#   type = object({
#     AAD_CLIENT_ID     = optional(string)
#     AAD_CLIENT_SECRET = optional(string)
#     AAD_TENANT_ID     = optional(string)
#     AAD_PRINCIPAL_ID  = optional(string)
#     SUBSCRIPTION_ID   = string
#   })

#   nullable = false
# }

variable "auto_connect" {
  description = "Automatically connect to the Kubernetes cluster from the host machine by overwriting the current context."
  type        = bool
  default     = true
}

variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Metadata module variables."
  type = object({
    market              = string
    sre_team            = string
    environment         = string
    product_name        = string
    business_unit       = string
    product_group       = string
    subscription_type   = string
    resource_group_type = string
    project             = string
    additional_tags     = map(string)
    location            = string
  })

  default = {
    business_unit       = ""
    environment         = ""
    market              = ""
    product_group       = ""
    product_name        = "hpcc"
    project             = ""
    resource_group_type = ""
    sre_team            = ""
    subscription_type   = ""
    additional_tags     = {}
    location            = ""
  }
}

variable "resource_groups" {
  description = "Resource group module variables."
  type        = any

  default = {
    azure_kubernetes_service = {
      tags = { "apps" = "aks" }
    }
  }
}

variable "use_existing_vnet" {
  description = "Information about the existing VNet to use. Overrides vnet variable."
  type = object({
    name                = string
    resource_group_name = string
    route_table_name    = string
    location            = string

    subnets = object({
      aks = object({
        name = string
      })
      hpc_cache = optional(object({
        name = string
      }))
    })
  })

  default = null
}

## DNS
#########
variable "internal_domain" {
  description = "DNS Domain name"
  type        = string
}

variable "dns_resource_group" {
  description = "DNS resource group name"
  type        = string
}

## Other AKS Vars
##################
variable "cluster_ordinal" {
  description = "Appended number to cluster name"
  type        = number
  default     = 1
}

variable "cluster_version" {
  description = "Kubernetes version to use for the Azure Kubernetes Service managed cluster."
  type        = string
  nullable    = false
}

variable "sku_tier" {
  description = "Pricing tier for the Azure Kubernetes Service managed cluster; \"free\" & \"paid\" are supported. For production clusters or clusters with more than 10 nodes this should be set to \"paid\"."
  type        = string
  nullable    = false
  default     = "free"

  validation {
    condition     = contains(["free", "paid"], var.sku_tier)
    error_message = "Available SKU tiers are \"free\" or \"paid\"."
  }
}

variable "rbac_bindings" {
  description = "User and groups to configure in Kubernetes ClusterRoleBindings; for Azure AD these are the IDs."
  type = object({
    cluster_admin_users = optional(map(any))
    cluster_view_users  = optional(map(any))
    cluster_view_groups = optional(list(string))
  })
  nullable = false
  default  = {}
}

variable "node_groups" {
  description = "Node groups to configure."
  type = map(object({
    node_arch           = optional(string)
    node_os             = optional(string)
    node_type           = optional(string)
    node_type_variant   = optional(string)
    node_type_version   = optional(string)
    node_size           = string
    single_group        = optional(bool)
    min_capacity        = optional(number)
    max_capacity        = number
    os_config           = optional(map(any))
    ultra_ssd           = optional(bool)
    placement_group_key = optional(string)
    max_pods            = optional(number)
    max_surge           = optional(string)
    labels              = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
    tags = optional(map(string))
  }))
  nullable = false
  default  = {}
}

variable "core_services_config" {
  description = "Core service configuration."
  type = object({
    alertmanager = object({
      smtp_host = string
      smtp_from = string
      receivers = optional(list(object({
        name              = string
        email_configs     = optional(any, [])
        opsgenie_configs  = optional(any, [])
        pagerduty_configs = optional(any, [])
        pushover_configs  = optional(any, [])
        slack_configs     = optional(any, [])
        sns_configs       = optional(any, [])
        victorops_configs = optional(any, [])
        webhook_configs   = optional(any, [])
        wechat_configs    = optional(any, [])
        telegram_configs  = optional(any, [])
      })))
      routes = optional(list(object({
        receiver            = string
        group_by            = optional(list(string))
        continue            = optional(bool)
        matchers            = list(string)
        group_wait          = optional(string)
        group_interval      = optional(string)
        repeat_interval     = optional(string)
        mute_time_intervals = optional(list(string))
        # active_time_intervals = optional(list(string))
      })))
    })
    cert_manager = optional(object({
      acme_dns_zones      = optional(list(string))
      additional_issuers  = optional(map(any))
      default_issuer_kind = optional(string)
      default_issuer_name = optional(string)
    }))
    coredns = optional(object({
      forward_zones = optional(map(any))
    }))
    external_dns = optional(object({
      additional_sources     = optional(list(string))
      private_domain_filters = optional(list(string))
      public_domain_filters  = optional(list(string))
    }))
    fluentd = optional(object({
      image_repository = optional(string)
      image_tag        = optional(string)
      additional_env   = optional(map(string))
      debug            = optional(bool)
      filters          = optional(string)
      route_config = optional(list(object({
        match  = string
        label  = string
        copy   = optional(bool)
        config = string
      })))
      routes  = optional(string)
      outputs = optional(string)
    }))
    grafana = optional(object({
      admin_password          = optional(string)
      additional_plugins      = optional(list(string))
      additional_data_sources = optional(list(any))
    }))
    ingress_internal_core = optional(object({
      domain           = string
      subdomain_suffix = optional(string)
      lb_source_cidrs  = optional(list(string))
      lb_subnet_name   = optional(string)
      public_dns       = optional(bool)
    }))
    prometheus = optional(object({
      remote_write = optional(any)
    }))
    storage = optional(object({
      file = optional(bool, true)
      blob = optional(bool, false)
    }), {})
  })
  nullable = false
}

variable "experimental" {
  description = "Configure experimental features."
  type = object({
    oms_agent                                    = optional(bool, false)
    oms_agent_log_analytics_workspace_id         = optional(string, null)
    oms_agent_create_configmap                   = optional(bool, true)
    oms_agent_containerlog_schema_version        = optional(string, "v1")
    windows_support                              = optional(bool, false)
    arm64                                        = optional(bool, false)
    node_group_os_config                         = optional(bool, false)
    azure_cni_max_pods                           = optional(bool, false)
    aad_pod_identity_finalizer_wait              = optional(string, null)
    fluent_bit_use_memory_buffer                 = optional(bool, false)
    fluentd_memory_override                      = optional(string, null)
    prometheus_memory_override                   = optional(string, null)
    workload_identity                            = optional(bool, false)
    control_plane_logging_log_analytics_disabled = optional(bool, false)
  })
  default = {}
}

variable "runbook" {
  description = "Information to configure multiple runbooks"
  type = list(object({
    runbook_name = optional(string, "aks_startstop_runbook") # name of the runbook
    runbook_type = optional(string, "PowerShell")            # type of the runbook
    script_name  = optional(string, "start_stop.ps1")        # desired content of the runbook
  }))

  default = [{}]
}

variable "aks_automation" {
  description = "Arguments to automate the Azure Kubernetes Cluster"
  type = object({
    automation_account_name       = string
    local_authentication_enabled  = optional(bool, false)
    public_network_access_enabled = optional(bool, false)

    schedule = list(object({
      description     = optional(string, "Stop the Kubernetes cluster.")
      schedule_name   = optional(string, "aks_stop")
      runbook_name    = optional(string, "aks_startstop_runbook") # name of the runbook
      frequency       = string
      interval        = string
      start_time      = string
      week_days       = list(string)
      operation       = optional(string, "stop")
      daylight_saving = optional(bool, false)
    }))
  })
}

variable "timezone" {
  description = "Name of timezone"
  type        = string
  default     = "America/New_York"
}

variable "sku_name" {
  description = "The SKU of the account"
  type        = string
  default     = "Basic"
}

variable "log_verbose" {
  description = "Verbose log option."
  type        = string
  default     = "true"
}

variable "log_progress" {
  description = "Progress log option."
  type        = string
  default     = "true"
}

variable "cluster_endpoint_access_cidrs" {
  description = "List of CIDR blocks which can access the Azure Kubernetes Service managed cluster API server endpoint, an empty list will not error but will block public access to the cluster."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.cluster_endpoint_access_cidrs) > 0
    error_message = "Cluster endpoint access CIDRS need to be explicitly set."
  }

  validation {
    condition     = alltrue([for c in var.cluster_endpoint_access_cidrs : can(regex("^(\\d{1,3}).(\\d{1,3}).(\\d{1,3}).(\\d{1,3})\\/(\\d{1,2})$", c))])
    error_message = "Cluster endpoint access CIDRS can only contain valid cidr blocks."
  }
}

variable "logging" {
  description = "Logging configuration."
  type = object({
    control_plane = object({
      log_analytics = object({
        enabled                       = bool
        workspace_id                  = optional(string)
        profile                       = optional(string, "audit-write-only")
        additional_log_category_types = optional(list(string), [])
        retention_enabled             = optional(bool, true)
        retention_days                = optional(number, 30)
      })

      storage_account = object({
        enabled                       = bool
        id                            = optional(string)
        profile                       = optional(string, "all")
        additional_log_category_types = optional(list(string), [])
        retention_enabled             = optional(bool, true)
        retention_days                = optional(number, 30)
      })
    })

    workloads = optional(object({
      core_service_log_level      = optional(string, "WARN")
      storage_account_logs        = optional(bool, false)
      storage_account_container   = optional(string, "workload")
      storage_account_path_prefix = optional(string, null)
    }), {})

    storage_account_config = optional(object({
      id = optional(string, null)
    }), {})

    extra_records = optional(map(string), {})
  })

  nullable = false

  default = {
    control_plane = {
      log_analytics = {
        enabled = false
      }
      storage_account = {
        enabled = false
      }
    }
  }
  validation {
    condition     = !var.logging.control_plane.log_analytics.enabled || var.logging.control_plane.log_analytics.workspace_id != null
    error_message = "Control plane logging to a log analytics workspace requires a workspace ID."
  }

  validation {
    condition     = !var.logging.control_plane.log_analytics.enabled || (var.logging.control_plane.log_analytics.profile != null && contains(["all", "audit-write-only", "minimal", "empty"], coalesce(var.logging.control_plane.log_analytics.profile, "empty")))
    error_message = "Control plane logging to a log analytics external workspace requires a profile."
  }

  validation {
    condition     = !var.logging.control_plane.storage_account.enabled || var.logging.control_plane.storage_account.id != null
    error_message = "Control plane logging to a storage account requires an ID."
  }

  validation {
    condition     = !var.logging.control_plane.storage_account.enabled || (var.logging.control_plane.storage_account.profile != null && contains(["all", "audit-write-only", "minimal", "empty"], coalesce(var.logging.control_plane.storage_account.profile, "empty")))
    error_message = "Control plane logging to a storage account requires profile."
  }
}

variable "hpcc_log_analytics_enabled" {
  description = "Should Log Analytics be enabled for HPCC?"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "Availability zones to use for the node groups."
  type        = list(number)
  nullable    = false
  default     = [1]
}
