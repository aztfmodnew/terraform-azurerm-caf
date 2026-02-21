# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock

resource "azurerm_management_lock" "management_lock" {
  name       = azurecaf_name.management_lock.result
  scope      = var.settings.scope
  lock_level = var.settings.lock_level
  notes      = try(var.settings.notes, null)
}
