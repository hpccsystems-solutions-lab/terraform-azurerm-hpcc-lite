locals {
  tags           = merge(var.metadata.additional_tags, { "owner" = var.owner.name, "owner_email" = var.owner.email })
  get_aks_config = fileexists("../aks/data/config.json") ? jsondecode(file("../aks/data/config.json")) : null
  hpcc_namespace = var.hpcc.existing_namespace != null ? var.hpcc.existing_namespace : var.hpcc.create_namespace == true ? kubernetes_namespace.hpcc[0].metadata[0].name : "default"
}
