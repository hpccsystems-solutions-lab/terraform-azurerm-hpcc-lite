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
    additional_tags     = optional(map(string))
  })

  nullable = false
}

variable "location" {
  description = "Azure location"
  type        = string

  default = "eastus"
}

variable "azure_log_analytics_workspace" {
  description = "Azure log analytics workspace attributes"
  type = object({
    unique_name                        = optional(bool)
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

variable "hpcc" {
  description = "HPCC Platform attributes"
  type = object({
    version            = optional(string, "latest")
    existing_namespace = optional(string)
    labels             = optional(object({ name = string }), { name = "hpcc" })
    create_namespace   = optional(bool, false)
  })

  nullable = false
}

variable "elastic4hpcclogs" {
  description = "The attributes for elastic4hpcclogs."
  type = object({
    internet_enabled           = optional(bool, true)
    name                       = optional(string, "myelastic4hpcclogs")
    atomic                     = optional(bool)
    recreate_pods              = optional(bool)
    reuse_values               = optional(bool)
    reset_values               = optional(bool)
    force_update               = optional(bool)
    cleanup_on_fail            = optional(bool)
    disable_openapi_validation = optional(bool)
    max_history                = optional(number)
    wait                       = optional(bool, true)
    dependency_update          = optional(bool, true)
    timeout                    = optional(number, 300)
    wait_for_jobs              = optional(bool)
    lint                       = optional(bool)
    remote_chart               = optional(string, "https://hpcc-systems.github.io/helm-chart")
    local_chart                = optional(string)
    version                    = optional(string, "latest")
  })

  default = null
}
