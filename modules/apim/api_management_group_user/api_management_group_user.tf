resource "azurerm_api_management_group_user" "resource" {
  user_id             = local.user_id
  group_name          = local.group_name
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name

  dynamic "timeouts" {
    for_each = var.settings.timeouts == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
