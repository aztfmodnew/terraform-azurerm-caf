/*
In addition to the Arguments listed above - the following Attributes are exported:

id - The ID of the Linux Function App.

custom_domain_verification_id - The identifier used by App Service to perform domain ownership verification via DNS TXT record.

default_hostname - The default hostname of the Linux Function App.

hosting_environment_id - The ID of the App Service Environment used by Function App.

identity - An identity block as defined below.

kind - The Kind value for this Linux Function App.

outbound_ip_address_list - A list of outbound IP addresses. For example ["52.23.25.3", "52.143.43.12"]

outbound_ip_addresses - A comma separated list of outbound IP addresses as a string. For example 52.23.25.3,52.143.43.12.

possible_outbound_ip_address_list - A list of possible outbound IP addresses, not all of which are necessarily in use. This is a superset of outbound_ip_address_list. For example ["52.23.25.3", "52.143.43.12"].

possible_outbound_ip_addresses - A comma separated list of possible outbound IP addresses as a string. For example 52.23.25.3,52.143.43.12,52.143.43.17. This is a superset of outbound_ip_addresses.

site_credential - A site_credential block as defined below.

An identity block exports the following:

principal_id - The Principal ID associated with this Managed Service Identity.

tenant_id - The Tenant ID associated with this Managed Service Identity.

A site_credential block exports the following:

name - The Site Credentials Username used for publishing.

password - The Site Credentials Password used for publishing.
*/

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

