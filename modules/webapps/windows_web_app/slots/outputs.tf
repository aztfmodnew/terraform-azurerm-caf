output "id" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.id
  description = "The ID of the Windows Web App Slot"
}

output "name" {
  value       = azurecaf_name.windows_web_app_slot.result
  description = "The CAF-compliant name of the Windows Web App Slot"
}

output "default_hostname" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.default_hostname
  description = "The default hostname of the Windows Web App Slot"
}

output "outbound_ip_addresses" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses"
}

output "outbound_ip_address_list" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.outbound_ip_address_list
  description = "A list of outbound IP addresses"
}

output "possible_outbound_ip_addresses" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.possible_outbound_ip_addresses
  description = "A comma separated list of possible outbound IP addresses"
}

output "possible_outbound_ip_address_list" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.possible_outbound_ip_address_list
  description = "A list of possible outbound IP addresses"
}

output "site_credential" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.site_credential
  description = "The site credential block"
  sensitive   = true
}

output "kind" {
  value       = azurerm_windows_web_app_slot.windows_web_app_slot.kind
  description = "The kind of the Windows Web App Slot"
}
