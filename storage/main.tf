module "storage" {
  source = "git@github.com:hpccsystems-solutions-lab/terraform-azurerm-hpcc-storage.git"

  owner                      = local.owner
  disable_naming_conventions = var.disable_naming_conventions
  metadata                   = local.metadata
  subnet_ids                 = local.subnet_ids
  storage_accounts           = var.storage_accounts
}
