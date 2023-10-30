module "storage" {
  #source = "github.com/gfortil/terraform-azurerm-hpcc-storage?ref=HPCC-27615"
  #source = "git@github.com:gfortil/terraform-azurerm-hpcc-storage?ref=HPCC-27615"
  #source = "/home/azureuser/tlhumphrey2/terraform-azurerm-hpcc-storage"
  source = "/home/azureuser/temp/HPCC-27615/terraform-azurerm-hpcc-storage"

  owner                      = var.owner
  disable_naming_conventions = var.disable_naming_conventions
  metadata                   = var.metadata
  subnet_ids                 = local.subnet_ids
  storage_accounts           = var.storage_accounts
}
