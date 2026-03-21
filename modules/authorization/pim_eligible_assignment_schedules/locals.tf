locals {
  principal_id = coalesce(
    try(var.settings.principal_id, null),
    try(var.remote_objects.managed_identities[try(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.managed_identity.key].principal_id, null),
    try(var.remote_objects.azuread_groups[try(var.settings.azuread_group.lz_key, var.client_config.landingzone_key)][var.settings.azuread_group.key].object_id, null)
  )
}
