output "id" {
  description = "Notification recipient ARM ID."
  value       = azurerm_api_management_notification_recipient_email.resource.id
}
output "api_management_id" {
  description = "Resolved parent APIM ARM ID."
  value       = local.api_management_id
}
output "email" {
  description = "Recipient email address."
  value       = azurerm_api_management_notification_recipient_email.resource.email
}
output "notification_type" {
  description = "Subscribed notification type."
  value       = azurerm_api_management_notification_recipient_email.resource.notification_type
}
