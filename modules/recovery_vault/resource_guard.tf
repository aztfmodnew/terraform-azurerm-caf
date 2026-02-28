resource "azurerm_recovery_services_vault_resource_guard_association" "resource_guard" {
  count = try(var.settings.resource_guard, null) == null ? 0 : 1

  vault_id = azurerm_recovery_services_vault.asr.id
  resource_guard_id = try(
    var.settings.resource_guard.id,
    var.remote_objects.resource_guards[try(var.settings.resource_guard.lz_key, var.client_config.landingzone_key)][var.settings.resource_guard.key].id
  )
}
