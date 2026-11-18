output "id" {
  description = "Notification recipient ARM ID."
  value       = azurerm_api_management_notification_recipient_user.resource.id
}
output "api_management_id" {
  description = "Resolved parent APIM ARM ID."
  value       = local.api_management_id
}
output "user_id" {
  description = "Resolved APIM-local recipient user identifier (not an ARM ID)."
  value       = local.user_id
}
output "notification_type" {
  description = "Subscribed notification type."
  value       = azurerm_api_management_notification_recipient_user.resource.notification_type
}
