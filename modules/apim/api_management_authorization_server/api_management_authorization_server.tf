resource "azurerm_api_management_authorization_server" "resource" {
  name                         = azurecaf_name.resource.result
  api_management_name          = local.api_management_name
  resource_group_name          = local.resource_group_name
  display_name                 = var.settings.display_name
  authorization_endpoint       = var.settings.authorization_endpoint
  authorization_methods        = var.settings.authorization_methods
  client_id                    = var.settings.client_id
  client_registration_endpoint = var.settings.client_registration_endpoint
  grant_types                  = var.settings.grant_types
  bearer_token_sending_methods = try(var.settings.bearer_token_sending_methods, null)
  client_authentication_method = try(var.settings.client_authentication_method, null)
  client_secret                = try(var.settings.client_secret, null)
  default_scope                = try(var.settings.default_scope, null)
  description                  = try(var.settings.description, null)
  resource_owner_password      = try(var.settings.resource_owner_password, null)
  resource_owner_username      = try(var.settings.resource_owner_username, null)
  support_state                = try(var.settings.support_state, null)
  token_endpoint               = try(var.settings.token_endpoint, null)
  dynamic "token_body_parameter" {
    for_each = var.settings.token_body_parameter
    content {
      name  = token_body_parameter.value.name
      value = token_body_parameter.value.value
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
