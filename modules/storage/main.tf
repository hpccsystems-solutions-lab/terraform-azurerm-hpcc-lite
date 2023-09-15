module "storage" {
  source = "github.com/gfortil/terraform-azurerm-hpcc-storage?ref=HPCC-27615"

  owner                      = var.owner
  disable_naming_conventions = var.disable_naming_conventions
  metadata                   = var.metadata
  virtual_network            = local.virtual_network
  storage_accounts           = var.storage_accounts
}
