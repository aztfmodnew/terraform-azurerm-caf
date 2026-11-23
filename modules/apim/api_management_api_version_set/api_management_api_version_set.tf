resource "azurerm_api_management_api_version_set" "resource" {
  name                = azurecaf_name.resource.result
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  display_name        = var.settings.display_name
  versioning_scheme   = var.settings.versioning_scheme
  description         = try(var.settings.description, null)
  version_header_name = try(var.settings.version_header_name, null)
  version_query_name  = try(var.settings.version_query_name, null)

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
