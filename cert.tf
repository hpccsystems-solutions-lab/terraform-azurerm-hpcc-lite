# resource "null_resource" "kubectl-manifest" {
#   count = var.cert_manager.enabled ? 1 : 0

#   provisioner "local-exec" {
#     command     = "kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.crds.yaml"
#     interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
#   }

#   depends_on = [
#     module.kubernetes
#   ]
# }

resource "null_resource" "openssl" {
  count = var.cert_manager.enabled ? 1 : 0

  provisioner "local-exec" {
    command     = "openssl req -x509 -newkey rsa:2048 -nodes -keyout ./tmp/ca.key -sha256 -days 1825 -out ./tmp/ca.crt -config ./ca-req.cfg"
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }

  depends_on = [
    module.kubernetes,
    helm_release.cert-manager
  ]
}

resource "null_resource" "kubernetes-secret" {
  count = var.cert_manager.enabled ? 1 : 0

  provisioner "local-exec" {
    command     = "kubectl create secret tls hpcc-local-issuer-key-pair --cert=./tmp/ca.crt --key=./tmp/ca.key -n hpcc"
    interpreter = local.is_windows_os ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }

  depends_on = [
    helm_release.cert-manager,
    null_resource.openssl
  ]
}

resource "helm_release" "cert-manager" {
  count = var.cert_manager.enabled ? 1 : 0

  name                       = "cert-manager"
  chart                      = can(var.cert_manager.remote_chart) ? "cert-manager" : var.cert_manager.local_chart
  repository                 = can(var.cert_manager.remote_chart) ? var.cert_manager.remote_chart : null
  version                    = can(var.cert_manager.version) ? var.cert_manager.version : "1.9.1"
  values                     = concat(var.cert_manager.default ? [] : [local.cert_manager], try([for v in var.cert_manager.values : file(v)], []))
  create_namespace           = true
  namespace                  = local.namespaces.hpcc.metadata.name
  atomic                     = try(var.cert_manager.atomic, false)
  force_update               = try(var.cert_manager.force_update, false)
  recreate_pods              = try(var.cert_manager.recreate_pods, false)
  reuse_values               = try(var.cert_manager.reuse_values, false)
  reset_values               = try(var.cert_manager.reset_values, false)
  cleanup_on_fail            = try(var.cert_manager.cleanup_on_fail, null)
  disable_openapi_validation = try(var.cert_manager.disable_openapi_validation, false)
  wait                       = try(var.cert_manager.wait, true)
  max_history                = try(var.cert_manager.max_history, 0)
  dependency_update          = try(var.cert_manager.dependency_update, false)
  timeout                    = try(var.cert_manager.timeout, 600)
  wait_for_jobs              = try(var.cert_manager.wait_for_jobs, false)
  lint                       = try(var.cert_manager.lint, false)
  skip_crds                  = false

  depends_on = [
    # null_resource.kubectl-manifest
    kubectl_manifest.cert-manager
  ]
}

resource "kubectl_manifest" "cert-manager" {
  count = var.cert_manager.enabled ? 1 : 0

  yaml_body         = file("${path.module}/values/cert-manager.crds.yaml")
  server_side_apply = true
  wait              = true

  depends_on = [
    module.kubernetes
  ]
}
