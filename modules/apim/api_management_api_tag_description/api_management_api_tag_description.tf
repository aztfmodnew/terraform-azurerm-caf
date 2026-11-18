resource "azurerm_api_management_api_tag_description" "resource" {
  api_tag_id                         = local.api_tag_id
  description                        = try(var.settings.description, null)
  external_documentation_url         = try(var.settings.external_documentation_url, null)
  external_documentation_description = try(var.settings.external_documentation_description, null)

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
