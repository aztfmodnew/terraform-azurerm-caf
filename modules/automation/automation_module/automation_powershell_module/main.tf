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

  timeouts {
    create = try(var.settings.timeouts.create, null)
    read   = try(var.settings.timeouts.read, null)
    update = try(var.settings.timeouts.update, null)
    delete = try(var.settings.timeouts.delete, null)
  }
}
