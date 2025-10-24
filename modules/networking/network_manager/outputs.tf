output "id" {
  value = azurerm_network_manager.network_manager.id
}

output "cross_tenant_scopes" {
  value = [for cross_tenant_scope in azurerm_network_manager.network_manager.cross_tenant_scopes : {
    management_groups = cross_tenant_scope.management_groups
    subscriptions     = cross_tenant_scope.subscriptions
    tenant_id         = cross_tenant_scope.tenant_id
  }]
}