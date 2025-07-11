output "id" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.id
  description = "The ID of the Windows Function App Slot"
}

output "name" {
  value       = azurecaf_name.windows_function_app_slot.result
  description = "The CAF-compliant name of the Windows Function App Slot"
}



output "custom_domain_verification_id" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.custom_domain_verification_id
  description = "The identifier used by App Service to perform domain ownership verification via DNS TXT record"
}

output "default_hostname" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.default_hostname
  description = "The default hostname of the Windows Function App Slot"
}

output "host_name_bindings" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.hosting_environment_id
  description = "The ID of the App Service Environment used by Function App Slot"
}

output "kind" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.kind
  description = "The Kind value for this Windows Function App Slot"
}

output "outbound_ip_addresses" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses"
}

output "outbound_ip_address_list" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.outbound_ip_address_list
  description = "A list of outbound IP addresses"
}

output "possible_outbound_ip_addresses" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.possible_outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses not currently in use by this Windows Function App Slot"
}

output "possible_outbound_ip_address_list" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.possible_outbound_ip_address_list
  description = "A list of possible outbound IP addresses not currently in use by this Windows Function App Slot"
}

output "site_credential" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.site_credential
  description = "A site_credential block containing the credentials for this Windows Function App Slot"
  sensitive   = true
}

output "identity" {
  value       = azurerm_windows_function_app_slot.windows_function_app_slot.identity
  description = "An identity block showing the Managed Service Identity information for this Windows Function App Slot"
}
