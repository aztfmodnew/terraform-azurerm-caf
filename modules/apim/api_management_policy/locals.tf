locals {
  api_management_id = coalesce(
    try(var.settings.api_management_id, null),
    try(var.settings.api_management.id, null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].id, null)
  )
}
