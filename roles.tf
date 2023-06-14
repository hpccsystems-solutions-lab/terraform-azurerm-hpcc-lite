# resource "kubernetes_cluster_role_binding" "aad-integration" {
#   count = var.aks.rbac.enabled ? 1 : 0
#   metadata {
#     name = "cluster-role"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-role"
#   }
#   dynamic "subject" {
#     for_each = var.aks.rbac.admin_object_ids

#     content {
#       kind      = "Group"
#       name      = subject.key
#       api_group = "rbac.authorization.k8s.io"
#     }
#   }

#   depends_on = [
#     module.kubernetes
#   ]
# }

# # resource "azurerm_role_assignment" "network-contributor" {
# #   count = var.aks.rbac.enabled ? 1 : 0

# #   scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${local.virtual_network.resource_group_name}"
# #   role_definition_name = "Network Contributor"
# #   principal_id         = module.kubernetes.principal_id
# # }

# resource "azurerm_role_assignment" "managed-identity-operator" {
#   count = var.aks.rbac.enabled ? 1 : 0

#   scope                = module.resource_group.id
#   role_definition_name = "Managed Identity Operator"
#   principal_id         = module.kubernetes.principal_id
# }

# resource "azurerm_role_assignment" "virtual-machine-contributor" {
#   count = var.aks.rbac.enabled ? 1 : 0

#   scope                = module.resource_group.id
#   role_definition_name = "Virtual Machine Contributor"
#   principal_id         = module.kubernetes.principal_id
# }

# resource "azurerm_role_assignment" "storage-blob-data-contributor" {
#   count = var.aks.rbac.enabled ? 1 : 0

#   scope                = module.resource_group.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = module.kubernetes.principal_id
# }

# resource "kubernetes_cluster_role" "general-cluster-roles" {
#   metadata {
#     name = "general-cluster-roles"
#   }

#   rule {
#     api_groups = ["", "extensions", "apps"] # "" indicates the core API group
#     resources  = ["*"]
#     verbs      = ["*"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "general-cluster-role-bindings" {
#   metadata {
#     name = "general-cluster-role-binding"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.general-cluster-roles.metadata[0].name
#   }
#   subject {
#     kind      = "User"
#     name      = "system:authenticated"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
