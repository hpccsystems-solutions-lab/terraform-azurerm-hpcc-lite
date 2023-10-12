resource "null_resource" "deploy_vnet" {

  provisioner "local-exec" {
    command     = "scripts/deploy vnet"
  }
}

resource "null_resource" "deploy_aks" {

  provisioner "local-exec" {
    command     = "scripts/deploy aks"
  }

  depends_on = [ null_resource.deploy_vnet ]
}

resource "null_resource" "deploy_hpcc" {

  provisioner "local-exec" {
    command     = "scripts/deploy hpcc"
  }

  depends_on = [  null_resource.deploy_aks ]
}
