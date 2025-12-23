output "id" {
  description = "Managed Redis instance ID."
  value       = azurerm_managed_redis.managed_redis.id
}

output "hostname" {
  description = "Managed Redis hostname."
  value       = azurerm_managed_redis.managed_redis.hostname
}

output "default_database" {
  description = "Default database details (id, port, access keys)."
  value       = try(azurerm_managed_redis.managed_redis.default_database[0], null)
}
