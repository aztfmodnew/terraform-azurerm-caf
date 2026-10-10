resource "azurecaf_name" "apim" {
  name          = var.settings.name
  resource_type = "azurerm_api_management_certificate"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
resource "azurerm_api_management_certificate" "apim" {
  name                = azurecaf_name.apim.result
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name
  data                = try(var.settings.data, null)
  password            = try(var.settings.password, null)
  key_vault_secret_id = try(coalesce(
    try(var.settings.key_vault_secret_id, null),
    try(var.settings.key_vault_id, null),
    try(var.remote_objects.keyvault_certificates[coalesce(try(var.settings.key_vault_secret.lz_key, null), var.client_config.landingzone_key)][var.settings.key_vault_secret.certificate_key].secret_id, null),
    try(var.remote_objects.keyvault_certificate_requests[coalesce(try(var.settings.key_vault_secret.lz_key, null), var.client_config.landingzone_key)][var.settings.key_vault_secret.certificate_request_key].secret_id, null)
  ), null)
  key_vault_identity_client_id = try(coalesce(
    try(var.settings.key_vault_identity_client_id, null),
    try(var.settings.key_vault_identity_client.id, null),
    try(var.remote_objects.managed_identities[coalesce(try(var.settings.key_vault_identity_client.lz_key, null), var.client_config.landingzone_key)][var.settings.key_vault_identity_client.key].client_id, null)
  ), null)

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}