resource "local_file" "config" {
  content  = module.storage.config
  filename = "${path.module}/data/config.json"
}
