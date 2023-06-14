variable "admin" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })

  validation {
    condition = try(
      regex("hpccdemo", var.admin.name) != "hpccdemo", true
      ) && try(
      regex("hpccdemo", var.admin.email) != "hpccdemo", true
      ) && try(
      regex("@example.com", var.admin.email) != "@example.com", true
    )
    error_message = "Your name and email are required in the admin block and must not contain hpccdemo or @example.com."
  }
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

# variable "disable_helm" {
#   description = "Disable Helm deployments by Terraform."
#   type        = bool
#   default     = false
# }

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
  type = object({
    release_name               = optional(string)
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
    remote_chart               = optional(string)
    local_chart                = optional(string)
    chart_version              = optional(string)
    image_version              = optional(string)
    image_root                 = optional(string)
    image_name                 = optional(string)
    values                     = optional(list(string))
    create_namespace           = optional(bool)
    namespace                  = optional(string)
    tls_enabled                = optional(bool)
    auto_connect               = optional(bool)
    auto_launch_eclwatch       = optional(bool)
    default_storage            = optional(bool)

    internet_enabled = optional(object({
      eclwatch   = optional(bool)
      eclqueries = optional(bool)
      sql2ecl    = optional(bool)
      esdl       = optional(bool)
      dfs        = optional(bool)
    }))
  })
}

variable "storage" {
  description = "Storage account arguments."
  type        = any
  default     = { default = false }
}

# variable "elastic4hpcclogs" {
#   description = "HPCC Helm chart variables."
#   type        = any
#   default     = { name = "myelastic4hpcclogs", enable = true }
# }

variable "registry" {
  description = "Use if image is hosted on a private docker repository."
  type        = any
  default     = {}
}

variable "aks_automation" {
  description = "Arguments to automate the Azure Kubernetes Cluster"
  type = object({
    local_authentication_enabled  = optional(bool, false)
    public_network_access_enabled = optional(bool, false)

    schedule = list(object({
      schedule_name   = string
      description     = string
      frequency       = string
      interval        = string
      start_time      = string
      week_days       = list(string)
      daylight_saving = optional(bool, false)
    }))
  })
}
