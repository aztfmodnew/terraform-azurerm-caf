resource "azurerm_api_management_identity_provider_aadb2c" "resource" {
  api_management_name    = local.api_management_name
  resource_group_name    = local.resource_group_name
  client_id              = var.settings.client_id
  client_secret          = var.settings.client_secret
  allowed_tenant         = var.settings.allowed_tenant
  authority              = var.settings.authority
  signin_tenant          = var.settings.signin_tenant
  signin_policy          = var.settings.signin_policy
  signup_policy          = var.settings.signup_policy
  client_library         = try(var.settings.client_library, null)
  password_reset_policy  = try(var.settings.password_reset_policy, null)
  profile_editing_policy = try(var.settings.profile_editing_policy, null)
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
