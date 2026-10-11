output "id" {
  description = "The ID of the Synapse Spark Pool."
  value       = azurerm_synapse_spark_pool.spark_pool.id
}

output "spark_pool" {
  description = "The Synapse Spark Pool resource attributes."
  value       = azurerm_synapse_spark_pool.spark_pool
}