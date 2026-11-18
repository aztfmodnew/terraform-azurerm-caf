resource "azurerm_api_management_email_template" "resource" {
  template_name       = var.settings.template_name
  api_management_name = local.api_management_name
  resource_group_name = local.resource_group_name
  subject             = var.settings.subject
  body                = var.settings.body
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
