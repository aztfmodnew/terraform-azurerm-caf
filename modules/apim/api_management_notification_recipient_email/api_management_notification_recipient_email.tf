resource "azurerm_api_management_notification_recipient_email" "resource" {
  api_management_id = local.api_management_id
  email             = var.settings.email
  notification_type = var.settings.notification_type
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
