output "id" {
  description = "The ID of the Azure Managed Grafana instance."
  value       = azurerm_dashboard_grafana.grafana.id
}

output "name" {
  description = "The name of the Azure Managed Grafana instance."
  value       = azurerm_dashboard_grafana.grafana.name
}

output "location" {
  description = "The Azure location of the Azure Managed Grafana instance."
  value       = azurerm_dashboard_grafana.grafana.location
}

output "resource_group_name" {
  description = "The resource group name of the Azure Managed Grafana instance."
  value       = azurerm_dashboard_grafana.grafana.resource_group_name
}

output "endpoint" {
  description = "The endpoint URL of the Grafana instance."
  value       = azurerm_dashboard_grafana.grafana.endpoint
}

output "grafana_version" {
  description = "The full Grafana software semantic version deployed."
  value       = azurerm_dashboard_grafana.grafana.grafana_version
}

output "grafana_major_version" {
  description = "The major version of Grafana deployed."
  value       = azurerm_dashboard_grafana.grafana.grafana_major_version
}

output "outbound_ip" {
  description = "List of outbound IPs if deterministic outbound IP is enabled."
  value       = try(azurerm_dashboard_grafana.grafana.outbound_ip, [])
}

output "identity" {
  description = "Identity block with principal_id and tenant_id."
  value       = try(azurerm_dashboard_grafana.grafana.identity, null)
}

output "sku" {
  description = "The SKU of the Grafana instance."
  value       = azurerm_dashboard_grafana.grafana.sku
}

output "rbac_object_id" {
  description = "The principal ID for RBAC assignments (if identity is enabled)."
  value       = try(azurerm_dashboard_grafana.grafana.identity[0].principal_id, null)
}
