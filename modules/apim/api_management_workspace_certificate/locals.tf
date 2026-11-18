locals {
  api_management_workspace_id = coalesce(
    var.settings.api_management_workspace_id,
    try(var.settings.api_management_workspace.id, null),
    try(var.remote_objects.api_management_workspace[coalesce(try(var.settings.api_management_workspace.lz_key, null), try(var.client_config.landingzone_key, null))][var.settings.api_management_workspace.key].id, null)
  )
  key_vault_secret_id = try(coalesce(
    var.settings.key_vault_secret_id,
    try(var.remote_objects.keyvault_certificates[coalesce(var.settings.key_vault_secret.lz_key, var.client_config.landingzone_key)][var.settings.key_vault_secret.certificate_key].secret_id, null),
    try(var.remote_objects.keyvault_certificate_requests[coalesce(var.settings.key_vault_secret.lz_key, var.client_config.landingzone_key)][var.settings.key_vault_secret.certificate_request_key].secret_id, null),
    try("${trimsuffix(var.remote_objects.keyvaults[coalesce(var.settings.key_vault.lz_key, var.client_config.landingzone_key)][var.settings.key_vault.key].vault_uri, "/")}/secrets/${var.settings.secret_name}", null)
  ), null)
  identity_client_id = try(coalesce(
    var.settings.user_assigned_identity_client_id,
    try(var.remote_objects.managed_identities[coalesce(var.settings.managed_identity.lz_key, var.client_config.landingzone_key)][var.settings.managed_identity.key].client_id, null)
  ), null)
}
