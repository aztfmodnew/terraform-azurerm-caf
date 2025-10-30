output "id" {
  value       = azurerm_private_endpoint.pep.id
  description = "The ID of the Private Endpoint"
}

output "name" {
  value       = azurerm_private_endpoint.pep.name
  description = "The name of the Private Endpoint"
}

output "private_dns_zone_group" {
  value       = azurerm_private_endpoint.pep.private_dns_zone_group
  description = "The private DNS zone group configuration"
}

output "private_dns_zone_configs" {
  value       = azurerm_private_endpoint.pep.private_dns_zone_configs
  description = "The private DNS zone configuration details"
}

output "custom_dns_configs" {
  value       = azurerm_private_endpoint.pep.custom_dns_configs
  description = "The custom DNS configurations"
}

output "network_interface" {
  value       = azurerm_private_endpoint.pep.network_interface
  description = "The network interface details of the private endpoint"
}

output "private_service_connection" {
  value       = azurerm_private_endpoint.pep.private_service_connection
  description = "The private service connection details"
}

output "private_ip_address" {
  value       = try(azurerm_private_endpoint.pep.private_service_connection[0].private_ip_address, null)
  description = "The private IP address of the private endpoint"
}

output "ip_configuration" {
  value       = azurerm_private_endpoint.pep.ip_configuration
  description = "The IP configuration details of the private endpoint"
}