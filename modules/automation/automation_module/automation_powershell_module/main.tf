resource "azurerm_automation_powershell72_module" "automation_powershell72_module" {
  name                  = var.settings.name
  automation_account_id = var.automation_account_id
  tags                  = local.tags

  module_link {
    uri = var.settings.module_link.uri

    dynamic "hash" {
      for_each = try(var.settings.module_link.hash, null) == null ? [] : [var.settings.module_link.hash]

      content {
        algorithm = hash.value.algorithm
        value     = hash.value.value
      }
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
