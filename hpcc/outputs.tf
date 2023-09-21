output "hpcc_namespace" {
  description = "The namespace where the HPCC Platform is deployed."
  value       = local.hpcc_namespace
}

output "eclwatch" {
  description = "Print the ECL Watch domain out."
  value       = local.svc_domains.eclwatch
}
