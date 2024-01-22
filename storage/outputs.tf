resource "local_file" "config" {
  content  = module.storage.config
  filename = "${path.module}/data/config.json"

  depends_on = [ module.storage ]
}
