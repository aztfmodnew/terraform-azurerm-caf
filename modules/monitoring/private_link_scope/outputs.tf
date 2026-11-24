output "id" {
  description = "The Azure Monitor Private Link Scope ID."
  value       = azurerm_monitor_private_link_scope.scope.id
}

output "name" {
  description = "The Azure Monitor Private Link Scope name."
  value       = azurerm_monitor_private_link_scope.scope.name
}

output "resource_group_name" {
  description = "The resource group containing the scope."
  value       = azurerm_monitor_private_link_scope.scope.resource_group_name
}

output "ingestion_access_mode" {
  description = "The scope ingestion access mode."
  value       = azurerm_monitor_private_link_scope.scope.ingestion_access_mode
}

output "query_access_mode" {
  description = "The scope query access mode."
  value       = azurerm_monitor_private_link_scope.scope.query_access_mode
}

output "scoped_services" {
  description = "Scoped Log Analytics and Application Insights resources, keyed by configuration key."
  value = {
    for key, service in azurerm_monitor_private_link_scoped_service.scoped_service : key => {
      id                 = service.id
      name               = service.name
      scope_name         = service.scope_name
      linked_resource_id = service.linked_resource_id
    }
  }
}

output "private_endpoints" {
  description = "Private endpoints created for the scope, keyed by configuration key."
  value       = module.private_endpoint
}
