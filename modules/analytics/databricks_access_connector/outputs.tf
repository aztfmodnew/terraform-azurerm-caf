output "id" {
  description = "The ID of the Manages a Databricks Access Connector."
  value       = azurerm_databricks_access_connector.databricks_access_connector.id
}

output "identity" {
  description = "The configured managed identity, including its principal and tenant IDs when available."
  value       = try(azurerm_databricks_access_connector.databricks_access_connector.identity, null)
}