output "id" {
  value       = azurerm_subnet_service_endpoint_storage_policy.subnet_service_endpoint_storage_policy.id
  description = "The ID of the Subnet Service Endpoint Storage Policy"
}

output "name" {
  value       = azurecaf_name.subnet_service_endpoint_storage_policy.result
  description = "The CAF-compliant name of the Subnet Service Endpoint Storage Policy"
}

output "location" {
  value       = azurerm_subnet_service_endpoint_storage_policy.subnet_service_endpoint_storage_policy.location
  description = "The location of the Subnet Service Endpoint Storage Policy"
}

output "resource_group_name" {
  value       = azurerm_subnet_service_endpoint_storage_policy.subnet_service_endpoint_storage_policy.resource_group_name
  description = "The resource group name of the Subnet Service Endpoint Storage Policy"
}

output "definitions" {
  value       = azurerm_subnet_service_endpoint_storage_policy.subnet_service_endpoint_storage_policy.definition
  description = "The definitions of the Subnet Service Endpoint Storage Policy"
}
