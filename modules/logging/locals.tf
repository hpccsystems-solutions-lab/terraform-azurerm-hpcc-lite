locals {
  tags = merge(var.metadata.additional_tags, { "owner" = var.owner.name, "owner_email" = var.owner.email })
  get_kubeconfig_data = fileexists("../aks/data/kubeconfig.json") ? jsondecode(file("../aks/data/kubeconfig.json")) : null

}
