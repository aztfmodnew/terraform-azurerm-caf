output "id" {
  value = azurerm_private_endpoint.pep.id
}

output "private_dns_zone_group" {
  value = azurerm_private_endpoint.pep.private_dns_zone_group
}

output "private_dns_zone_configs" {
  value = azurerm_private_endpoint.pep.private_dns_zone_configs
}

output "custom_dns_configs" {
  value = azurerm_private_endpoint.pep.custom_dns_configs
}

output "network_interface" {
  value = azurerm_private_endpoint.pep.network_interface
}

output "private_service_connection" {
  value = azurerm_private_endpoint.pep.private_service_connection
}

output "private_ip_address" {
  value       = try(azurerm_private_endpoint.pep.private_service_connection[0].private_ip_address, null)
  description = "The private IP address of the private endpoint"
}