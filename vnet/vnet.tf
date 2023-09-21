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
