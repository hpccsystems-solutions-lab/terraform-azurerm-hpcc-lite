module "subscription" {
  source          = "github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

module "naming" {
  source = "github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

module "metadata" {
  source = "github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.1"

  naming_rules = module.naming.yaml

  market              = var.metadata.market
  location            = var.metadata.location
  sre_team            = var.metadata.sre_team
  environment         = var.metadata.environment
  product_name        = var.metadata.product_name
  business_unit       = var.metadata.business_unit
  product_group       = var.metadata.product_group
  subscription_type   = var.metadata.subscription_type
  resource_group_type = var.metadata.resource_group_type
  subscription_id     = data.azurerm_subscription.current.id
  project             = var.metadata.project
}

module "resource_groups" {
  source = "github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.1.0"

  for_each = local.resource_groups

  unique_name = true
  location    = module.metadata.location
  names       = module.metadata.names
  tags        = merge(local.tags, each.value.tags)
}

module "virtual_network" {
  source = "github.com/Azure-Terraform/terraform-azurerm-virtual-network.git?ref=v5.0.0"

  naming_rules = module.naming.yaml

  resource_group_name = module.resource_groups["virtual_network"].name
  location            = module.resource_groups["virtual_network"].location
  names               = module.metadata.names
  tags                = module.metadata.tags

  enforce_subnet_names = false

  address_space = ["10.0.0.0/24"]
  aks_subnets = {
    hpcc = {
      private = {
        cidrs             = ["10.0.0.0/25"]
        service_endpoints = ["Microsoft.Storage"]
      }
      public = {
        cidrs             = ["10.0.0.128/25"]
        service_endpoints = ["Microsoft.Storage"]
      }
      route_table = {
        disable_bgp_route_propagation = true
        routes = {
          internet = {
            address_prefix = "0.0.0.0/0"
            next_hop_type  = "Internet"
          }
          local-vnet-10-1-0-0-21 = {
            address_prefix = "10.0.0.0/24"
            next_hop_type  = "vnetlocal"
          }
        }
      }
    }
  }
}
