locals {
  api_management_id = coalesce(
    var.settings.api_management_id,
    try(var.settings.api_management.id, null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.api_management.key].id, null)
  )
}
