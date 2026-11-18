resource "azurerm_api_management_workspace_named_value" "resource" {
  name                        = azurecaf_name.resource.result
  api_management_workspace_id = local.api_management_workspace_id
  display_name                = var.settings.display_name
  secret                      = try(var.settings.secret, false)
  tags                        = try(var.settings.tags, null)
  value                       = try(var.settings.value, null)
  dynamic "value_from_key_vault" {
    for_each = var.settings.value_from_key_vault == null ? [] : [var.settings.value_from_key_vault]
    content {
      secret_id          = local.key_vault_secret_id
      identity_client_id = local.identity_client_id
    }
  }
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
