locals {
  api_management_id = coalesce(
    var.settings.api_management_id,
    try(var.settings.api_management.id, null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.api_management.key].id, null)
  )
  user = try(var.remote_objects.api_management_users[coalesce(try(var.settings.user.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.user.key], null)
  user_id = coalesce(
    var.settings.user_id,
    try(var.settings.user.user_id, null),
    try(local.user.user_id, null),
    # Existing CAF user modules export only their ARM ID.
    try(reverse(split("/", local.user.id))[0], null)
  )
}
