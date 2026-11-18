resource "azurerm_api_management_api_schema" "resource" {
  schema_id           = azurecaf_name.resource.result
  api_name            = local.api_name
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  content_type        = var.settings.content_type
  value               = try(var.settings.value, null)
  components          = try(var.settings.components, null)
  definitions         = try(var.settings.definitions, null)

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
