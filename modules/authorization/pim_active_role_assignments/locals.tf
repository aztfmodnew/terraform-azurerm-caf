locals {
  scope_management_group_selector = try(coalesce(
    try(var.settings.scope_management_group, null),
    try(var.settings.management_group, null)
  ), null)

  scope_subscription_selector = try(coalesce(
    try(var.settings.scope_subscription, null),
    try(var.settings.subscription, null)
  ), null)

  role_definition_selector  = try(var.settings.role_definition, null)
  managed_identity_selector = try(var.settings.managed_identity, null)
  azuread_group_selector    = try(var.settings.azuread_group, null)

  scope = coalesce(
    try(var.settings.scope, null),
    try(var.remote_objects.management_groups[coalesce(try(local.scope_management_group_selector.lz_key, null), var.client_config.landingzone_key)][local.scope_management_group_selector.key].id, null),
    try(var.remote_objects.subscriptions[coalesce(try(local.scope_subscription_selector.lz_key, null), var.client_config.landingzone_key)][local.scope_subscription_selector.key].id, null),
    try(local.active_scope_from_management_group_data, null),
    try(local.active_scope_from_subscription_data, null)
  )

  role_definition_id_resolved = coalesce(
    try(var.settings.role_definition_id, null),
    try(var.remote_objects.role_definitions[coalesce(try(local.role_definition_selector.lz_key, null), var.client_config.landingzone_key)][local.role_definition_selector.key].role_definition_id, null),
    try(var.remote_objects.role_definitions[coalesce(try(local.role_definition_selector.lz_key, null), var.client_config.landingzone_key)][local.role_definition_selector.key].id, null),
    try(local.active_role_definition_from_data, null)
  )

  role_definition_id = (
    try(startswith(local.role_definition_id_resolved, "/providers/"), false) &&
    try(startswith(local.role_definition_id_resolved, "/subscriptions/"), false)
    ? "${local.scope}${local.role_definition_id_resolved}" : local.role_definition_id_resolved
  )

  principal_id = coalesce(
    try(var.settings.principal_id, null),
    try(var.remote_objects.managed_identities[coalesce(try(local.managed_identity_selector.lz_key, null), var.client_config.landingzone_key)][local.managed_identity_selector.key].principal_id, null),
    try(var.remote_objects.azuread_groups[coalesce(try(local.azuread_group_selector.lz_key, null), var.client_config.landingzone_key)][local.azuread_group_selector.key].object_id, null),
    try(local.active_principal_from_managed_identity_data, null),
    try(local.active_principal_from_azuread_group_data, null)
  )
}
