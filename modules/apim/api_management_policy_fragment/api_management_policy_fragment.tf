resource "azurerm_api_management_policy_fragment" "resource" {
  name              = azurecaf_name.resource.result
  api_management_id = local.api_management_id
  value             = var.settings.value
  format            = try(var.settings.format, "xml")
  description       = try(var.settings.description, null)

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
