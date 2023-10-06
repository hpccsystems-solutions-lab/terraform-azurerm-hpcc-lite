resource "null_resource" "deploy_vnet" {

  provisioner "local-exec" {
    command     = "scripts/deploy.sh vnet"
  }
}

resource "null_resource" "deploy_aks" {

  provisioner "local-exec" {
    command     = "scripts/deploy.sh aks"
  }

  depends_on = [ null_resource.deploy_vnet ]
}

resource "null_resource" "deploy_hpcc" {

  provisioner "local-exec" {
    command     = "scripts/deploy.sh hpcc"
  }

  depends_on = [  null_resource.deploy_aks ]
}
