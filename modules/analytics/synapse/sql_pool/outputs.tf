output "id" {
  description = "The ID of the Synapse SQL Pool."
  value       = azurerm_synapse_sql_pool.sql_pool.id
}

output "sql_pool" {
  description = "The Synapse SQL Pool resource attributes."
  value       = azurerm_synapse_sql_pool.sql_pool
}