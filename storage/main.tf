module "storage" {
  #source = "github.com/gfortil/terraform-azurerm-hpcc-storage?ref=HPCC-27615"
  #source = "git@github.com:gfortil/terraform-azurerm-hpcc-storage?ref=HPCC-27615"
  #source = "/home/azureuser/tlhumphrey2/terraform-azurerm-hpcc-storage"
  #source = "/home/azureuser/temp/HPCC-27615/terraform-azurerm-hpcc-storage"
  source = "git@github.com:hpccsystems-solutions-lab/terraform-azurerm-hpcc-storage.git?ref=HPCC-27615-add-rm-0000-cidr"

  owner                      = local.owner
  disable_naming_conventions = var.disable_naming_conventions
  metadata                   = local.metadata
  subnet_ids                 = local.subnet_ids
  storage_accounts           = var.storage_accounts
}
