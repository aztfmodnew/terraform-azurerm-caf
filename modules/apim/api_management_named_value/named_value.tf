resource "azurerm_api_management_named_value" "named_value" {
  name                = azurecaf_name.named_value.result
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  display_name        = var.settings.display_name
  value               = try(var.settings.value, null)
  secret              = try(var.settings.secret, false)
  tags                = try(var.settings.tags, null)

  dynamic "value_from_key_vault" {
    for_each = var.settings.value_from_key_vault == null ? [] : [var.settings.value_from_key_vault]

    content {
      secret_id          = local.key_vault_secret_id
      identity_client_id = local.identity_client_id
    }
  }

  dynamic "timeouts" {
    for_each = var.settings.timeouts == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
