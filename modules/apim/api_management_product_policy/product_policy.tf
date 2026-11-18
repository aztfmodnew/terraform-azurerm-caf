resource "azurerm_api_management_product_policy" "policy" {
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  product_id          = local.product_id
  xml_content         = var.settings.xml_content
  xml_link            = var.settings.xml_link

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
