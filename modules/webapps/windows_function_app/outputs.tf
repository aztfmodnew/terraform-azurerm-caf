output "name" {
  value       = azurecaf_name.windows_function_app.result
  description = "The CAF-compliant name of the Windows Function App"
}

output "id" {
  value       = azurerm_windows_function_app.windows_function_app.id
  description = "The ID of the Windows Function App"
}

output "rbac_id" {
  value       = azurerm_windows_function_app.windows_function_app.id
  description = "The ID of the Windows Function App"
}

output "custom_domain_verification_id" {
  value       = azurerm_windows_function_app.windows_function_app.custom_domain_verification_id
  description = "The identifier used by App Service to perform domain ownership verification via DNS TXT record"
}

output "default_hostname" {
  value       = azurerm_windows_function_app.windows_function_app.default_hostname
  description = "The default hostname of the Windows Function App"
}

output "hosting_environment_id" {
  value       = azurerm_windows_function_app.windows_function_app.hosting_environment_id
  description = "The ID of the App Service Environment used by Function App"
}

output "identity" {
  value = length(azurerm_windows_function_app.windows_function_app.identity) > 0 ? {
    principal_id = azurerm_windows_function_app.windows_function_app.identity[0].principal_id
    tenant_id    = azurerm_windows_function_app.windows_function_app.identity[0].tenant_id
  } : null
  description = "An identity block as defined below"
}

output "kind" {
  value       = azurerm_windows_function_app.windows_function_app.kind
  description = "The Kind value for this Windows Function App"
}

output "outbound_ip_address_list" {
  value       = azurerm_windows_function_app.windows_function_app.outbound_ip_address_list
  description = "A list of outbound IP addresses"
}

output "outbound_ip_addresses" {
  value       = azurerm_windows_function_app.windows_function_app.outbound_ip_addresses
  description = "A comma separated list of outbound IP addresses as a string"
}

output "possible_outbound_ip_address_list" {
  value       = azurerm_windows_function_app.windows_function_app.possible_outbound_ip_address_list
  description = "A list of possible outbound IP addresses, not all of which are necessarily in use"
}

output "possible_outbound_ip_addresses" {
  value       = azurerm_windows_function_app.windows_function_app.possible_outbound_ip_addresses
  description = "A comma separated list of possible outbound IP addresses as a string"
}

output "site_credential" {
  value = length(azurerm_windows_function_app.windows_function_app.site_credential) > 0 ? {
    name     = azurerm_windows_function_app.windows_function_app.site_credential[0].name
    password = azurerm_windows_function_app.windows_function_app.site_credential[0].password
  } : null
  description = "A site_credential block as defined below"
}

output "slots" {
  value       = module.slots
  description = "The Windows Function App Slots"
}
