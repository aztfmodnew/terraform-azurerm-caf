output "id" {
  value       = azurerm_linux_web_app_slot.linux_web_app_slot.id
  description = "The ID of the Linux Web App Slot"
}

output "name" {
  value       = azurecaf_name.linux_web_app_slot.result
  description = "The CAF-compliant name of the Linux Web App Slot"
}

output "default_hostname" {
  value       = azurerm_linux_web_app_slot.linux_web_app_slot.default_hostname
  description = "The default hostname of the Linux Web App Slot"
}

output "outbound_ip_addresses" {
  value       = azurerm_linux_web_app_slot.linux_web_app_slot.outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses"
}

output "possible_outbound_ip_addresses" {
  value       = azurerm_linux_web_app_slot.linux_web_app_slot.possible_outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses, not all of which are necessarily in use"
}

output "site_credential" {
  value       = azurerm_linux_web_app_slot.linux_web_app_slot.site_credential
  description = "A site_credential block"
  sensitive   = true
}

output "identity" {
  value       = try(azurerm_linux_web_app_slot.linux_web_app_slot.identity, null)
  description = "An identity block"
}
