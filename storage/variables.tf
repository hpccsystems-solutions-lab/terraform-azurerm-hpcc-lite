variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "virtual_network" {
  description = "Subnet IDs"
  type = list(object({
    vnet_name           = string
    resource_group_name = string
    subnet_name         = string
    subscription_id     = optional(string)
  }))
  default = null
}

variable "storage_accounts" {
  type = map(object({
    delete_protection                    = optional(bool)
    prefix_name                          = string
    storage_type                         = string
    authorized_ip_ranges                 = optional(map(string))
    replication_type                     = optional(string, "ZRS")
    subnet_ids                           = optional(map(string))
    file_share_retention_days            = optional(number, 7)
    access_tier                          = optional(string, "Hot")
    account_kind                         = string
    account_tier                         = string
    blob_soft_delete_retention_days      = optional(number, 7)
    container_soft_delete_retention_days = optional(number, 7)

    planes = map(object({
      category = string
      name     = string
      sub_path = string
      size     = number
      sku      = optional(string)
      rwmany   = bool
      protocol = optional(string, "nfs")
    }))
  }))
}
