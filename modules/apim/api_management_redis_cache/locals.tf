locals {
  connection_string = coalesce(
    try(var.settings.connection_string, null),
    try(var.remote_objects.redis_caches[coalesce(try(var.settings.redis_cache.lz_key, null), var.client_config.landingzone_key)][var.settings.redis_cache.key].primary_connection_string, null)
  )
  api_management_id = coalesce(
    try(var.settings.api_management_id, null),
    try(var.settings.api_management.id, null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].id, null)
  )
  redis_cache_id = try(coalesce(
    try(var.settings.redis_cache_id, null),
    try(var.settings.redis_cache.id, null),
    try(var.remote_objects.redis_caches[coalesce(try(var.settings.redis_cache.lz_key, null), var.client_config.landingzone_key)][var.settings.redis_cache.key].id, null)
  ), null)
}
