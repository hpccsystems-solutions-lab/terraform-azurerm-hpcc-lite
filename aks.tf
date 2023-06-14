module "kubernetes" {
  source = "github.com/Azure-Terraform/terraform-azurerm-kubernetes.git?ref=v4.2.1"

  cluster_name        = local.cluster_name
  location            = module.resource_group.location
  names               = local.names
  tags                = local.tags
  resource_group_name = module.resource_group.name
  identity_type       = "UserAssigned" # Allowed values: UserAssigned or SystemAssigned
  rbac = {
    enabled        = false
    ad_integration = false
  }

  network_plugin         = "azure"
  configure_network_role = true

  virtual_network = {
    subnets = {
      private = {
        id = local.virtual_network.private_subnet_id
      }
      public = {
        id = local.virtual_network.public_subnet_id
      }
    }
    route_table_id = local.virtual_network.route_table_id
  }

  node_pools = var.node_pools

  default_node_pool = "system" //name of the sub-key, which is the default node pool.

}

resource "kubernetes_secret" "sa_secret" {
  for_each = local.storage_accounts

  metadata {
    name = "${each.key}-azure-secret"
  }

  data = {
    "azurestorageaccountname" = "${each.key}"
    "azurestorageaccountkey"  = "${data.azurerm_storage_account.hpccsa[each.key].primary_access_key}"
  }

  type = "Opaque"
}

# resource "kubernetes_secret" "private_docker_registry" {
#   count = can(var.registry.server) && can(var.registry.username) && can(var.registry.password) ? 1 : 0
#   metadata {
#     name = "docker-cfg"
#   }
#   type = "kubernetes.io/dockerconfigjson"
#   data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "${var.registry.server}" = {
#           "username" = var.registry.username
#           "password" = var.registry.password
#           "email"    = var.admin.email
#           "auth"     = base64encode("${var.registry.username}:${var.registry.password}")
#         }
#       }
#     })
#   }
# }
