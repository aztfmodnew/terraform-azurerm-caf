output "id" {
  description = "Route Server resource id"
  value       = azurerm_route_server.route_server.id
}

output "name" {
  description = "Route Server name"
  value       = azurerm_route_server.route_server.name
}

output "subnet_id" {
  description = "Subnet ID used by the Route Server"
  value       = azurerm_route_server.route_server.subnet_id
}

output "public_ip_address_id" {
  description = "Public IP address ID associated with the Route Server"
  value       = azurerm_route_server.route_server.public_ip_address_id
}
