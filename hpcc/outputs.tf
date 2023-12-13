output "eclwatch_url" {
  description = "Print the ECL Watch URL."
  value       = format("https://%s.%s",var.a_record_name, var.aks_dns_zone_name)
}

output "deployment_resource_group" {
  description = "Print the name of the deployment resource group."
  value       = local.get_aks_config.resource_group_name
}

output "external_storage_config_exists" {
  description = "Print whether external storage exists, i.e. true of false."
  value       = fileexists("../storage/data/config.json") ? true : false
}

resource "local_file" "config" {
  content  = "hpcc successfully deployed"
  filename = "${path.module}/data/config.json"

  depends_on = [ module.hpcc ]
}
