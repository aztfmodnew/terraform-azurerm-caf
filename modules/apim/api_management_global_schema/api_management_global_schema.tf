resource "azurerm_api_management_global_schema" "resource" {
  schema_id           = azurecaf_name.resource.result
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  type                = var.settings.type
  value               = var.settings.value
  description         = try(var.settings.description, null)

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
