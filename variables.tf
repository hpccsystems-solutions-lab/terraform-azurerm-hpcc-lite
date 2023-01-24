variable "admin" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })
}

variable "expose_services" {
  description = "Expose ECLWatch and elastic4hpcclogs to the Internet. This is not secure. Please consider before using it."
  type        = bool
  default     = false
}

variable "auto_launch_eclwatch" {
  description = "Auto launch ELCWatch after each connection to the cluster."
  type        = bool
  default     = false
}

variable "auto_connect" {
  description = "Automatically connect to the Kubernetes cluster from the host machine by overwriting the current context."
  type        = bool
  default     = false
}

variable "disable_helm" {
  description = "Disable Helm deployments by Terraform."
  type        = bool
  default     = false
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
  }
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)

  default = {
    "" = ""
  }
}

variable "resource_group" {
  description = "Resource group module variables."
  type        = any

  default = {
    unique_name = true
  }
}

variable "virtual_network" {
  description = "Virtual network attributes."
  type        = any
  default     = null
}

variable "node_pools" {
  description = "node pools"
  type        = any # top level keys are node pool names, sub-keys are subset of node_pool_defaults keys
  default     = { default = {} }
}

variable "hpcc" {
  description = "HPCC Helm chart variables."
  type        = any
  default     = { name = "myhpcck8s" }
}

variable "storage" {
  description = "Storage account arguments."
  type        = any
  default     = { default = false }
}

variable "registry" {
  description = "Use if image is hosted on a private docker repository."
  type        = any
  default     = {}
}

variable "elastic4hpcclogs" {
  description = "The attributes for elastic4hpcclogs."
  type = object({
    internet_enabled           = optional(bool)
    name                       = string
    atomic                     = optional(bool)
    recreate_pods              = optional(bool)
    reuse_values               = optional(bool)
    reset_values               = optional(bool)
    force_update               = optional(bool)
    cleanup_on_fail            = optional(bool)
    disable_openapi_validation = optional(bool)
    max_history                = optional(number)
    wait                       = optional(bool)
    dependency_update          = optional(bool)
    timeout                    = optional(number)
    wait_for_jobs              = optional(bool)
    lint                       = optional(bool)
    remote_chart               = string
    local_chart                = optional(string)
    version                    = optional(string)
  })

  default = null
}

variable "azure_log_analytics_workspace" {
  description = "Azure log analytics workspace attributes"
  type = object({
    name                               = string
    daily_quota_gb                     = optional(number)
    internet_ingestion_enabled         = optional(bool)
    internet_query_enabled             = optional(bool)
    reservation_capacity_in_gb_per_day = optional(number)
    retention_in_days                  = optional(number)
    sku                                = optional(string)
    tags                               = optional(map(string))
    use_existing_workspace = optional(object({
      name                = string
      resource_group_name = string
    }))
    linked_storage_account = optional(object({
      data_source_type    = string
      storage_account_ids = list(string)
    }))
  })

  default = null
}

variable "azure_log_analytics_creds" {
  description = "Credentials for the Azure log analytics workspace"
  type = object({
    AAD_TENANT_ID     = string
    AAD_CLIENT_ID     = string
    AAD_CLIENT_SECRET = string
    AAD_PRINCIPAL_ID  = string
  })
  sensitive = true
  default   = null
}
