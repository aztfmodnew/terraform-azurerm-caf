resource "azurerm_chaos_studio_target" "target" {
  location           = local.location
  target_resource_id = local.target_resource_id
  target_type        = var.settings.target_type

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}
