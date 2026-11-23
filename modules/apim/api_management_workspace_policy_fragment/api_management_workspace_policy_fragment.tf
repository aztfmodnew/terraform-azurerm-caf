resource "azurerm_api_management_workspace_policy_fragment" "resource" {
  name                        = azurecaf_name.resource.result
  api_management_workspace_id = local.api_management_workspace_id
  xml_content                 = var.settings.xml_content
  xml_format                  = try(var.settings.xml_format, "xml")
  description                 = try(var.settings.description, null)
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
