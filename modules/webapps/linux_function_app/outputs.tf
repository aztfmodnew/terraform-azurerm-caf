
output "id" {
  value = azurerm_linux_function_app.linux_function_app.id
}

output "custom_domain_verification_id" {
  value = azurerm_linux_function_app.linux_function_app.custom_domain_verification_id
}

output "default_hostname" {
  value = azurerm_linux_function_app.linux_function_app.default_hostname
}

output "hosting_environment_id" {
  value = azurerm_linux_function_app.linux_function_app.hosting_environment_id
}

output "identity" {
  value = length(azurerm_linux_function_app.linux_function_app.identity) > 0 ? {
    principal_id = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
    tenant_id    = azurerm_linux_function_app.linux_function_app.identity[0].tenant_id
  } : null
}

output "kind" {
  value = azurerm_linux_function_app.linux_function_app.kind
}

output "outbound_ip_address_list" {
  value = azurerm_linux_function_app.linux_function_app.outbound_ip_address_list
}

output "outbound_ip_addresses" {
  value = azurerm_linux_function_app.linux_function_app.outbound_ip_addresses
}

output "possible_outbound_ip_address_list" {
  value = azurerm_linux_function_app.linux_function_app.possible_outbound_ip_address_list
}

output "possible_outbound_ip_addresses" {
  value = azurerm_linux_function_app.linux_function_app.possible_outbound_ip_addresses
}

output "site_credential" {
  value = length(azurerm_linux_function_app.linux_function_app.site_credential) > 0 ? {
    name     = azurerm_linux_function_app.linux_function_app.site_credential[0].name
    password = azurerm_linux_function_app.linux_function_app.site_credential[0].password
  } : null
}

output "rbac_id" {
  value = azurerm_linux_function_app.linux_function_app.id
}