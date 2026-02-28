# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cost_anomaly_alert

resource "azurerm_cost_anomaly_alert" "cost_anomaly_alert" {
  name               = azurecaf_name.cost_anomaly_alert.result
  display_name       = var.settings.display_name
  email_addresses    = var.settings.email_addresses
  email_subject      = var.settings.email_subject
  subscription_id    = try(var.settings.subscription_id, null)
  notification_email = try(var.settings.notification_email, null)
  message            = try(var.settings.message, null)

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
