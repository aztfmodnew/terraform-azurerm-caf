resource "azurerm_databricks_access_connector" "databricks_access_connector" {
  name                = coalesce(var.name, var.settings.name)
  resource_group_name = local.resource_group.name
  location            = lookup(var.settings, "region", null) == null ? local.resource_group.location : var.global_settings.regions[var.settings.region]
  tags                = local.tags

  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = identity.value.type
      identity_ids = concat(local.managed_identities, coalesce(try(identity.value.identity_ids, null), []))
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
