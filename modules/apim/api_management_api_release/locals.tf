locals {
  api_id = coalesce(
    try(var.settings.api_id, null),
    try(var.settings.api.id, null),
    try(var.remote_objects.api_management_api[coalesce(try(var.settings.api.lz_key, null), var.client_config.landingzone_key)][var.settings.api.key].id, null)
  )
}
