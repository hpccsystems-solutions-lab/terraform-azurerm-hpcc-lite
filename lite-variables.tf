###############################################################################
# Prompted variables (user will be asked to supply them at plan/apply time
# if a .tfvars file is not supplied); there are no default values
###############################################################################
variable "external_storage_desired" {
  description = "If you definitely want ephemeral storage instead of external, this should be false. For external storage this should be true"
  type        = bool
  default     = false
}
variable "enable_thor" {
  description = "REQUIRED.  If you want a thor cluster."
  type        = bool
}

variable "a_record_name" {
  type        = string
  description = "OPTIONAL: dns zone A record name"
  default     = ""
}

variable "aks_admin_email" {
  type        = string
  description = "REQUIRED.  Email address of the administrator of this HPCC Systems cluster.\nExample entry: jane.doe@hpccsystems.com"
  validation {
    condition     = length(regexall("^[^@]+@[^@]+$", var.aks_admin_email)) > 0
    error_message = "Value must at least look like a valid email address."
  }
}

variable "aks_admin_name" {
  type        = string
  description = "REQUIRED.  Name of the administrator of this HPCC Systems cluster.\nExample entry: Jane Doe"
}

variable "admin_username" {
  type        = string
  description = "REQUIRED.  Username of the administrator of this HPCC Systems cluster.\nExample entry: jdoe"
  validation {
    condition     = length(var.admin_username) > 1 && length(regexall(" ", var.admin_username)) == 0
    error_message = "Value must at least two characters in length and contain no spaces."
  }
}

variable "aks_azure_region" {
  type        = string
  description = "REQUIRED.  The Azure region abbreviation in which to create these resources.\nMust be one of [\"eastus\", \"eastus2\", \"centralus\"].\nExample entry: eastus2"
  validation {
    condition     = contains(["eastus", "eastus2", "centralus"], var.aks_azure_region)
    error_message = "Value must be one of [\"eastus\", \"eastus2\", \"centralus\"]."
  }
}

variable "enable_code_security" {
  description = "REQUIRED.  Enable code security?\nIf true, only signed ECL code will be allowed to create embedded language functions, use PIPE(), etc.\nExample entry: false"
  type        = bool
}

variable "enable_roxie" {
  description = "REQUIRED.  Enable ROXIE?\nThis will also expose port 8002 on the cluster.\nExample entry: false"
  type        = bool
}

variable "extra_tags" {
  description = "OPTIONAL.  Map of name => value tags that can will be associated with the cluster.\nFormat is '{\"name\"=\"value\" [, \"name\"=\"value\"]*}'.\nThe 'name' portion must be unique.\nTo add no tags, enter '{}'. This is OPTIONAL and defaults to an empty string map."
  type        = map(string)
  default     = {}
}

variable "aks_dns_zone_resource_group_name" {
  type        = string
  description = "OPTIONAL: Name of the resource group containing the dns zone."
  default     = ""
}

variable "aks_dns_zone_name" {
  type        = string
  description = "OPTIONAL: dns zone name. The name of existing dns zone."
  default     = ""
}

variable "hpcc_user_ip_cidr_list" {
  description = "OPTIONAL.  List of additional CIDR addresses that can access this HPCC Systems cluster.\nDefault value is '[]' which means no CIDR addresses.\nTo open to the internet, add \"0.0.0.0/0\"."
  type        = list(string)
  default     = []
}

variable "hpcc_version" {
  description = "REQUIRED.  The version of HPCC Systems to install.\nOnly versions in nn.nn.nn format are supported."
  type        = string
  validation {
    condition     = (var.hpcc_version == "latest") || can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(-rc\\d{1,3})?$", var.hpcc_version))
    error_message = "Value must be 'latest' OR in nn.nn.nn format and 8.6.0 or higher."
  }
}

variable "aks_admin_ip_cidr_map" {
  description = "OPTIONAL.  Map of name => CIDR IP addresses that can administrate this AKS.\nFormat is '{\"name\"=\"cidr\" [, \"name\"=\"cidr\"]*}'.\nThe 'name' portion must be unique.\nDefault value is '{}' means no CIDR addresses.\nThe corporate network and your current IP address will be added automatically, and these addresses will have access to the HPCC cluster as a user."
  type        = map(string)
  default     = {}
}

variable "aks_max_node_count" {
  type        = number
  description = "REQUIRED.  The maximum number of VM nodes to allocate for the HPCC Systems node pool.\nMust be 2 or more."
  validation {
    condition     = var.aks_max_node_count >= 2
    error_message = "Value must be 2 or more."
  }
}

variable "aks_node_size" {
  type        = string
  description = "REQUIRED.  The VM size for each node in the HPCC Systems node pool.\nRecommend \"Standard_B4ms\" or better.\nSee https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general for more information."
}

variable "storage_data_gb" {
  type        = number
  description = "REQUIRED.  The amount of storage reserved for data in gigabytes.\nMust be 10 or more.\nIf a storage account is defined (see below) then this value is ignored."
  validation {
    condition     = var.storage_data_gb >= 10
    error_message = "Value must be 10 or more."
  }
}

variable "storage_lz_gb" {
  type        = number
  description = "REQUIRED.  The amount of storage reserved for the landing zone in gigabytes.\nMust be 1 or more.\nIf a storage account is defined (see below) then this value is ignored."
  validation {
    condition     = var.storage_lz_gb >= 1
    error_message = "Value must be 1 or more."
  }
}

variable "thor_max_jobs" {
  type        = number
  description = "REQUIRED.  The maximum number of simultaneous Thor jobs allowed.\nMust be 1 or more."
  validation {
    condition     = var.thor_max_jobs >= 1
    error_message = "Value must be 1 or more."
  }
}

variable "thor_num_workers" {
  type        = number
  description = "REQUIRED.  The number of Thor workers to allocate.\nMust be 1 or more."
  validation {
    condition     = var.thor_num_workers >= 1
    error_message = "Value must be 1 or more."
  }
}

###############################################################################
# Optional variables
###############################################################################

variable "authn_htpasswd_filename" {
  type        = string
  description = "OPTIONAL.  If you would like to use htpasswd to authenticate users to the cluster, enter the filename of the htpasswd file.  This file should be uploaded to the Azure 'dllsshare' file share in order for the HPCC processes to find it.\nA corollary is that persistent storage is enabled.\nAn empty string indicates that htpasswd is not to be used for authentication.\nExample entry: htpasswd.txt"
  default     = ""
}

variable "hpcc_namespace" {
  description = "Kubernetes namespace where resources will be created."
  type = object({
    prefix_name      = string
    labels           = map(string)
    create_namespace = bool
  })
  default = {
    prefix_name = "hpcc"
    labels = {
      name = "hpcc"
    }
    create_namespace = false
  }
}

variable "enable_premium_storage" {
  type        = bool
  description = "OPTIONAL.  If true, premium ($$$) storage will be used for the following storage shares: Dali.\nDefaults to false."
  default     = false
}

variable "storage_account_name" {
  type        = string
  description = "OPTIONAL.  If you are attaching to an existing storage account, enter its name here.\nLeave blank if you do not have a storage account.\nIf you enter something here then you must also enter a resource group for the storage account.\nExample entry: my-product-sa"
  default     = ""
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "OPTIONAL.  If you are attaching to an existing storage account, enter its resource group name here.\nLeave blank if you do not have a storage account.\nIf you enter something here then you must also enter a name for the storage account."
  default     = ""
}
