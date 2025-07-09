output "name" {
  value       = azurecaf_name.linux_web_app.result
  description = "The CAF-compliant name of the Linux Web App"
}

output "id" {
  value = azurerm_linux_web_app.linux_web_app.id
}

output "custom_domain_verification_id" {
  value = azurerm_linux_web_app.linux_web_app.custom_domain_verification_id
}

output "hosting_environment_id" {
  value = azurerm_linux_web_app.linux_web_app.hosting_environment_id
}

output "default_hostname" {
  value = azurerm_linux_web_app.linux_web_app.default_hostname
}

output "kind" {
  value = azurerm_linux_web_app.linux_web_app.kind
}

output "outbound_ip_address_list" {
  value = azurerm_linux_web_app.linux_web_app.outbound_ip_address_list
}

output "outbound_ip_addresses" {
  value = azurerm_linux_web_app.linux_web_app.outbound_ip_addresses
}

output "possible_outbound_ip_address_list" {
  value = azurerm_linux_web_app.linux_web_app.possible_outbound_ip_address_list
}

output "possible_outbound_ip_addresses" {
  value = azurerm_linux_web_app.linux_web_app.possible_outbound_ip_addresses
}

output "site_credential" {
  value     = azurerm_linux_web_app.linux_web_app.site_credential
  sensitive = true
}

output "identity" {
  value = azurerm_linux_web_app.linux_web_app.identity
}

output "slots" {
  value = module.slots
}
