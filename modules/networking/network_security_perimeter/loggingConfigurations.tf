resource "azapi_resource" "loggingConfigurations" {
  for_each = var.settings.logging_configurations

  type                 = "Microsoft.Network/networkSecurityPerimeters/loggingConfigurations@2025-07-01"
  name                 = each.value.name
  parent_id            = azapi_resource.networkSecurityPerimeter.id
  ignore_null_property = true

  body = {
    properties = {
      enabledLogCategories = try(each.value.enabled_log_categories, null)
      version              = try(each.value.version, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
