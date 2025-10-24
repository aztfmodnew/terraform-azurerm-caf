output "id" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.id
}

output "custom_domain_verification_id" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.custom_domain_verification_id
}

output "default_hostname" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.default_hostname
}

output "hosting_environment_id" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.hosting_environment_id
}

output "identity" {
  value = {
    principal_id = azurerm_linux_function_app_slot.linux_function_app_slot.identity[0].principal_id
    tenant_id    = azurerm_linux_function_app_slot.linux_function_app_slot.identity[0].tenant_id
  }
}

output "kind" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.kind
}

output "outbound_ip_address_list" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.outbound_ip_address_list
}

output "outbound_ip_addresses" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.outbound_ip_addresses
}

output "possible_outbound_ip_address_list" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.possible_outbound_ip_address_list
}

output "possible_outbound_ip_addresses" {
  value = azurerm_linux_function_app_slot.linux_function_app_slot.possible_outbound_ip_addresses
}

output "site_credential" {
  value = {
    name     = azurerm_linux_function_app_slot.linux_function_app_slot.site_credential[0].name
    password = azurerm_linux_function_app_slot.linux_function_app_slot.site_credential[0].password
  }
}

