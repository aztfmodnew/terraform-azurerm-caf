locals {
  scope = coalesce(
    try(var.settings.scope, null),
    try(var.remote_objects.management_groups[coalesce(try(var.settings.scope_management_group.lz_key, null), var.client_config.landingzone_key)][var.settings.scope_management_group.key].id, null),
    try(var.remote_objects.subscriptions[coalesce(try(var.settings.scope_subscription.lz_key, null), var.client_config.landingzone_key)][var.settings.scope_subscription.key].id, null)
  )

  role_definition_id_resolved = coalesce(
    try(var.settings.role_definition_id, null),
    try(var.remote_objects.role_definitions[coalesce(try(var.settings.role_definition.lz_key, null), var.client_config.landingzone_key)][var.settings.role_definition.key].role_definition_id, null),
    try(var.remote_objects.role_definitions[coalesce(try(var.settings.role_definition.lz_key, null), var.client_config.landingzone_key)][var.settings.role_definition.key].id, null)
  )

  role_definition_id = try(startswith(local.role_definition_id_resolved, "/providers/"), false) ? "${local.scope}${local.role_definition_id_resolved}" : local.role_definition_id_resolved
}
