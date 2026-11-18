locals {
  api_management_name = coalesce(
    try(var.settings.api_management.name, null),
    try(var.remote_objects.api_management[coalesce(try(var.settings.api_management.lz_key, null), var.client_config.landingzone_key)][var.settings.api_management.key].name, null)
  )

  resource_group_name = coalesce(
    var.settings.resource_group_name,
    try(var.settings.resource_group.name, null),
    try(var.resource_group.name, null),
    try(var.remote_objects.resource_groups[coalesce(try(var.settings.resource_group.lz_key, null), var.client_config.landingzone_key)][var.settings.resource_group.key].name, null)
  )

  key_vault_secret_id = var.settings.value_from_key_vault == null ? null : coalesce(
    try(var.settings.value_from_key_vault.secret_id, null),
    try("${trimsuffix(var.remote_objects.keyvaults[coalesce(var.settings.value_from_key_vault.key_vault.lz_key, var.client_config.landingzone_key)][var.settings.value_from_key_vault.key_vault.key].vault_uri, "/")}/secrets/${var.settings.value_from_key_vault.secret_name}", null)
  )

  identity_client_id = var.settings.value_from_key_vault == null ? null : (
    try(var.settings.value_from_key_vault.identity_client_id, null) != null ? var.settings.value_from_key_vault.identity_client_id :
    try(var.settings.value_from_key_vault.managed_identity, null) == null ? null :
    var.remote_objects.managed_identities[coalesce(var.settings.value_from_key_vault.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.value_from_key_vault.managed_identity.key].client_id
  )
}
