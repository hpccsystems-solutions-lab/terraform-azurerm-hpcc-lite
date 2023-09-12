resource "azurerm_user_assigned_identity" "tlh-uaid" {
  resource_group_name   = module.resource_groups["azure_kubernetes_service"].name
  location              = module.metadata.location
  name                  = "tlh-aks-uaid-1"  
}        

resource "azurerm_role_assignment" "owner" {
  scope = format("/subscriptions/%s", data.azurerm_subscription.current.subscription_id)
  role_definition_name = "Owner"
  principal_id       = azurerm_user_assigned_identity.tlh-uaid.principal_id
}
