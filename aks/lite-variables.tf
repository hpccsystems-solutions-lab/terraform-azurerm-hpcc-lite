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
  description = "REQUIRED.  The Azure region abbreviation in which to create these resources.\nMust be one of [\"eastus\", \"eastus2\", \"centralus\"].\nExample entry: eastus2"
  validation {
    condition     = contains(["eastus", "eastus2", "centralus"], var.aks_azure_region)
    error_message = "Value must be one of [\"eastus\", \"eastus2\", \"centralus\"]."
  }
}

variable "aks_enable_roxie" {
  description = "REQUIRED.  Enable ROXIE?\nThis will also expose port 8002 on the cluster.\nExample entry: false"
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
