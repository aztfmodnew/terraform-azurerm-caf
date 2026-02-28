output "id" {
  value = azurerm_notification_hub_namespace.notification_hub_namespace.id
}

output "name" {
  value = azurerm_notification_hub_namespace.notification_hub_namespace.name
}

output "notification_hubs" {
  value = azurerm_notification_hub.notification_hub
}

output "authorization_rules" {
  value     = azurerm_notification_hub_authorization_rule.notification_hub_authorization_rule
  sensitive = true
}
