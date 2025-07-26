output "id" {
  value = azurerm_redis_cache.redis.id
}

output "hostname" {
  value = azurerm_redis_cache.redis.hostname
}

output "ssl_port" {
  value = azurerm_redis_cache.redis.ssl_port
}

output "port" {
  value = azurerm_redis_cache.redis.port
}

output "primary_access_key" {
  value = azurerm_redis_cache.redis.primary_access_key
}

output "secondary_access_key" {
  value = azurerm_redis_cache.redis.secondary_access_key
}

output "primary_connection_string" {
  value = azurerm_redis_cache.redis.primary_connection_string
}

output "secondary_connection_string" {
  value = azurerm_redis_cache.redis.secondary_connection_string
}

output "redis_cache" {
  value = azurerm_redis_cache.redis
}
# Hybrid naming outputs
output "name" {
  value       = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
