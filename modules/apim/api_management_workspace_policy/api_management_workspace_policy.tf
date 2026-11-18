resource "azurerm_api_management_workspace_policy" "resource" {
  api_management_workspace_id = local.api_management_workspace_id
  xml_content                 = try(var.settings.xml_content, null)
  xml_link                    = try(var.settings.xml_link, null)
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
