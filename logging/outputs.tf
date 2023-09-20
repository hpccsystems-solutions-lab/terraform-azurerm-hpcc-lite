output "logaccess_body" {
  description = "logaccess configuration to apply to the HPCC helm deployment."
  value       = module.logging.logaccess_body
}

output "workspace_resource_id" {
  description = "The resource ID of the workspace"
  value       = module.logging.workspace_resource_id
}

output "workspace_id" {
  description = "The Azure Analytics Workspace ID"
  value       = module.logging.workspace_id
}

output "hpcc_namespace" {
  description = "The namespace where the Kubernetes secret has been created and in which HPCC must be deployed."
  value       = var.hpcc.create_namespace ? kubernetes_namespace.hpcc[0].metadata[0].name : var.hpcc.namespace_prefix
}

resource "local_file" "logaccess_body" {
  content  = module.logging.logaccess_body
  filename = "${path.module}/data/logaccess_body.yaml"
}

resource "local_file" "workspace_resource_id" {
  content  = module.logging.workspace_resource_id
  filename = "${path.module}/data/workspace_resource_id.txt"
}

resource "local_file" "hpcc_namespace" {
  count = var.hpcc.create_namespace ? 1 : 0

  content  = var.hpcc.create_namespace ? kubernetes_namespace.hpcc[0].metadata[0].name : var.hpcc.namespace_prefix
  filename = "${path.module}/data/hpcc_namespace.txt"
}
