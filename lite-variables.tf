# All 'aks_' variables are before any other variables.
variable "aks_4nodepools" {
  description = "If true 4 nodepools are used. If false 2 are used."
  type        = bool
  default     = false
}

variable "aks_logging_monitoring_enabled" {
  description = "Used to get logging and monitoring of kubernetes and hpcc cluster."
  type        = bool
  default     = false
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

variable "aks_azure_region" {
  type        = string
  description = "REQUIRED.  The Azure region abbreviation in which to create these resources.\nExample entry: eastus2"
}

variable "aks_enable_roxie" {
  description = "If you want roxie then this variable must be set to true.  Enable ROXIE?\nThis will also expose port 18002 on the cluster.\nExample entry: false"
  type        = bool
  default     = false
}

variable "aks_dns_zone_resource_group_name" {
  type        = string
  description = "REQUIRED. Name of the resource group containing the dns zone."
}

variable "aks_dns_zone_name" {
  type        = string
  description = "REQUIRED. dns zone name. The name of existing dns zone."
}

variable "aks_admin_ip_cidr_map" {
  description = "OPTIONAL.  Map of name => CIDR IP addresses that can administrate this AKS.\nFormat is '{\"name\"=\"cidr\" [, \"name\"=\"cidr\"]*}'.\nThe 'name' portion must be unique.\nDefault value is '{}' means no CIDR addresses.\nThe corporate network and your current IP address will be added automatically, and these addresses will have access to the HPCC cluster as a user."
  type        = map(string)
  default     = {}
}

variable "aks_nodepools_max_capacity" {
  type        = number
  description = "The max capacity (or maximum node count) of all hopcc nodepools."
  default     = 400
}

variable "aks_roxie_node_size" {
  type        = string
  description = "The size of the roxie nodes. Possibilities are 'large', 'xlarge', '2xlarge', and '4xlarge'."
  validation {
      condition = (length(regexall("^[24]*x*large", var.aks_roxie_node_size)) == 1)

      error_message = "All node sizes must be one of the following: large, xlarge, 2xlarge, or 4xlarge."
  }
  default     = "xlarge"
}

variable "aks_serv_node_size" {
  type        = string
  description = "The size of the serv nodes. Possibilities are 'large', 'xlarge', '2xlarge', and '4xlarge'."
  validation {
      condition = (length(regexall("^[24]*x*large", var.aks_serv_node_size)) == 1)

      error_message = "All node sizes must be one of the following: large, xlarge, 2xlarge, or 4xlarge."
  }
  default     = "2xlarge"
}

variable "aks_spray_node_size" {
  type        = string
  description = "The size of the spray nodes. Possibilities are 'large', 'xlarge', '2xlarge', and '4xlarge'."
  validation {
      condition = (length(regexall("^[24]*x*large", var.aks_spray_node_size)) == 1)

      error_message = "All node sizes must be one of the following: large, xlarge, 2xlarge, or 4xlarge."
  }
  default     = "large"
}

variable "aks_thor_node_size" {
  type        = string
  description = "The size of the thor nodes. Possibilities are 'large', 'xlarge', '2xlarge', and '4xlarge'."
  validation {
      condition = (length(regexall("^[24]*x*large", var.aks_thor_node_size)) == 1)

      error_message = "All node sizes must be one of the following: large, xlarge, 2xlarge, or 4xlarge."
  }
  default     = "xlarge"
}
#===== end of aks variables =====

variable "my_azure_id" {
  description = "REQUIRED. The id of your azure account."
  type        = string
}

variable "external_storage_desired" {
  description = "If you want external storage instead of ephemeral, this should be true. For ephemeral storage this should be false"
  type        = bool
  default     = false
}

variable "enable_thor" {
  description = "REQUIRED.  If you want a thor cluster."
  type        = bool
  default     = true
}

variable "a_record_name" {
  type        = string
  description = "OPTIONAL: dns zone A record name"
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "REQUIRED.  Username of the administrator of this HPCC Systems cluster.\nExample entry: jdoe"
  validation {
    condition     = length(var.admin_username) > 1 && length(regexall(" ", var.admin_username)) == 0
    error_message = "Value must at least two characters in length and contain no spaces."
  }
}

variable "enable_code_security" {
  description = "REQUIRED.  Enable code security?\nIf true, only signed ECL code will be allowed to create embedded language functions, use PIPE(), etc.\nExample entry: false"
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "OPTIONAL.  Map of name => value tags that can will be associated with the cluster.\nFormat is '{\"name\"=\"value\" [, \"name\"=\"value\"]*}'.\nThe 'name' portion must be unique.\nTo add no tags, enter '{}'. This is OPTIONAL and defaults to an empty string map."
  type        = map(string)
  default     = {}
}

variable "hpcc_user_ip_cidr_list" {
  description = "OPTIONAL.  List of additional CIDR addresses that can access this HPCC Systems cluster.\nDefault value is '[]' which means no CIDR addresses.\nTo open to the internet, add \"0.0.0.0/0\"."
  type        = list(string)
  default     = []
}

variable "hpcc_version" {
  description = "The version of HPCC Systems to install.\nOnly versions in nn.nn.nn format are supported. Default is 'latest'"
  type        = string
  validation {
    condition     = (var.hpcc_version == "latest") || can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(-rc\\d{1,3})?$", var.hpcc_version))
    error_message = "Value must be 'latest' OR in nn.nn.nn format and 8.6.0 or higher."
  }
  default = "latest"
}

variable "storage_data_gb" {
  type        = number
  description = "REQUIRED.  The amount of storage reserved for data in gigabytes.\nMust be 10 or more.\nIf a storage account is defined (see below) then this value is ignored."
  validation {
    condition     = var.storage_data_gb >= 10
    error_message = "Value must be 10 or more."
  }
  default    = 100
}

variable "storage_lz_gb" {
  type        = number
  description = "REQUIRED.  The amount of storage reserved for the landing zone in gigabytes.\nMust be 1 or more.\nIf a storage account is defined (see below) then this value is ignored."
  validation {
    condition     = var.storage_lz_gb >= 1
    error_message = "Value must be 1 or more."
  }
  default    = 25
}

variable "thor_max_jobs" {
  type        = number
  description = "REQUIRED.  The maximum number of simultaneous Thor jobs allowed.\nMust be 1 or more."
  validation {
    condition     = var.thor_max_jobs >= 1
    error_message = "Value must be 1 or more."
  }
  default    = 1
}

variable "thor_num_workers" {
  type        = number
  description = "REQUIRED.  The number of Thor workers to allocate.\nMust be 1 or more."
  validation {
    condition     = var.thor_num_workers >= 1
    error_message = "Value must be 1 or more."
  }
  default    = 2
}

###############################################################################
# Optional variables
###############################################################################

variable "authn_htpasswd_filename" {
  type        = string
  description = "OPTIONAL.  If you would like to use htpasswd to authenticate users to the cluster, enter the filename of the htpasswd file.  This file should be uploaded to the Azure 'dllsshare' file share in order for the HPCC processes to find it.\nA corollary is that persistent storage is enabled.\nAn empty string indicates that htpasswd is not to be used for authentication.\nExample entry: htpasswd.txt"
  default     = ""
}

variable "enable_premium_storage" {
  type        = bool
  description = "OPTIONAL.  If true, premium ($$$) storage will be used for the following storage shares: Dali.\nDefaults to false."
  default     = false
}
