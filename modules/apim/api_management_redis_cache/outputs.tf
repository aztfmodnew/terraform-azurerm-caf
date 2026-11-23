output "id" {
  description = "APIM external Redis cache ARM resource ID."
  value       = azurerm_api_management_redis_cache.resource.id
}
output "name" {
  description = "CAF-generated external cache name."
  value       = azurerm_api_management_redis_cache.resource.name
}
output "redis_cache_id" {
  description = "Backing Redis cache ARM ID, if supplied."
  value       = azurerm_api_management_redis_cache.resource.redis_cache_id
}
