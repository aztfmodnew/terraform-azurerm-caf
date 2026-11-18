locals {
  api_management_workspace_id = coalesce(
    var.settings.api_management_workspace_id,
    try(var.settings.api_management_workspace.id, null),
    try(var.remote_objects.api_management_workspace[coalesce(try(var.settings.api_management_workspace.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.api_management_workspace.key].id, null)
  )
  key_vault_secret_id = try(coalesce(
    try(var.settings.value_from_key_vault.secret_id, null),
    try("${trimsuffix(var.remote_objects.keyvaults[coalesce(var.settings.value_from_key_vault.key_vault.lz_key, var.client_config.landingzone_key)][var.settings.value_from_key_vault.key_vault.key].vault_uri, "/")}/secrets/${var.settings.value_from_key_vault.secret_name}", null)
  ), null)
  identity_client_id = try(coalesce(
    try(var.settings.value_from_key_vault.identity_client_id, null),
    try(var.remote_objects.managed_identities[coalesce(var.settings.value_from_key_vault.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.value_from_key_vault.managed_identity.key].client_id, null)
  ), null)
}
