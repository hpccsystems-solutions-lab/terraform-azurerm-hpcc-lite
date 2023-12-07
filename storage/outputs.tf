resource "local_file" "config" {
  description = "File containing configuration of external storage."
  content  = module.storage.config
  filename = "${path.module}/data/config.json"

  depends_on = [ module.storage ]
}
