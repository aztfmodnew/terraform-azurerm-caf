resource "azurerm_cognitive_account_project" "project" {
  name                 = var.settings.name
  cognitive_account_id = var.cognitive_account_id
  location             = local.location
  description          = try(var.settings.description, null)
  display_name         = try(var.settings.display_name, null)

  identity {
    type         = local.managed_identity_type
    identity_ids = contains(["userassigned", "systemassigned, userassigned"], lower(local.managed_identity_type)) ? local.managed_identities : null
  }

  tags = local.tags

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, "30m")
      read   = try(timeouts.value.read, "5m")
      update = try(timeouts.value.update, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}
