resource "null_resource" "deploy_vnet" {

  provisioner "local-exec" {
    command     = "scripts/deploy vnet"
  }
}

resource "null_resource" "deploy_aks" {

  provisioner "local-exec" {
    command     = "scripts/deploy aks ${var.my_azure_id}"
  }

  depends_on = [ null_resource.deploy_vnet ]
}

resource "null_resource" "deploy_storage" {
  count = (var.external_storage_desired == true)? 1 : 0

  provisioner "local-exec" {
    command     = "scripts/deploy storage"
  }

  depends_on = [ null_resource.deploy_vnet, null_resource.deploy_aks ]
}

resource "null_resource" "external_storage" {
  count = (var.external_storage_desired == true)? 1 : 0

  provisioner "local-exec" {
    command     = "scripts/external_storage ${path.module} ${var.external_storage_desired}"
  }

  #depends_on = [ null_resource.deploy_vnet, null_resource.deploy_aks ]
  depends_on = [ null_resource.deploy_vnet ]
}

resource "null_resource" "deploy_hpcc" {

  provisioner "local-exec" {
    command     = "scripts/deploy hpcc"
  }

  depends_on = [  null_resource.deploy_aks, null_resource.deploy_vnet, null_resource.external_storage ]
}
