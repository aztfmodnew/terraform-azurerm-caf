resource "azurerm_api_management_workspace_certificate" "resource" {
  name                             = azurecaf_name.resource.result
  api_management_workspace_id      = local.api_management_workspace_id
  certificate_data_base64          = try(var.settings.certificate_data_base64, null)
  password                         = try(var.settings.password, null)
  key_vault_secret_id              = local.key_vault_secret_id
  user_assigned_identity_client_id = local.identity_client_id
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
