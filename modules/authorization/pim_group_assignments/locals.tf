locals {
  assignment_mode = lower(var.settings.assignment_mode)

  group_selector = try(var.settings.group, null)

  principal_group_selector = try(var.settings.principal_group, null)
  principal_user_selector  = try(var.settings.principal_user, null)

  group_id = coalesce(
    try(var.settings.group_id, null),
    try(var.remote_objects.azuread_groups[coalesce(try(local.group_selector.lz_key, null), var.client_config.landingzone_key)][local.group_selector.key].object_id, null),
    try(var.remote_objects.azuread_groups[coalesce(try(local.group_selector.lz_key, null), var.client_config.landingzone_key)][local.group_selector.key].id, null),
    try(local.group_id_from_data, null)
  )

  principal_id = coalesce(
    try(var.settings.principal_id, null),
    try(var.remote_objects.azuread_groups[coalesce(try(local.principal_group_selector.lz_key, null), var.client_config.landingzone_key)][local.principal_group_selector.key].object_id, null),
    try(var.remote_objects.azuread_groups[coalesce(try(local.principal_group_selector.lz_key, null), var.client_config.landingzone_key)][local.principal_group_selector.key].id, null),
    try(var.remote_objects.azuread_users[coalesce(try(local.principal_user_selector.lz_key, null), var.client_config.landingzone_key)][local.principal_user_selector.key].rbac_id, null),
    try(var.remote_objects.azuread_users[coalesce(try(local.principal_user_selector.lz_key, null), var.client_config.landingzone_key)][local.principal_user_selector.key].object_id, null),
    try(local.principal_group_id_from_data, null),
    try(local.principal_user_id_from_data, null)
  )
}
