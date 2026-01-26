resource "azurerm_chaos_studio_capability" "capability" {
  capability_type        = var.settings.capability_type
  chaos_studio_target_id = local.chaos_studio_target_id

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}
