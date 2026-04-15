locals {
  principal_id = coalesce(
    try(var.settings.principal_id, null),
    try(var.remote_objects.managed_identities[coalesce(try(var.settings.managed_identity.lz_key, null), var.client_config.landingzone_key)][var.settings.managed_identity.key].principal_id, null),
    try(var.remote_objects.azuread_groups[coalesce(try(var.settings.azuread_group.lz_key, null), var.client_config.landingzone_key)][var.settings.azuread_group.key].object_id, null)
  )
}
