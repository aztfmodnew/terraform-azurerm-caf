resource "azurerm_api_management_identity_provider_aad" "resource" {
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  client_id           = var.settings.client_id
  client_secret       = var.settings.client_secret
  allowed_tenants     = var.settings.allowed_tenants
  client_library      = try(var.settings.client_library, null)
  signin_tenant       = try(var.settings.signin_tenant, null)
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
