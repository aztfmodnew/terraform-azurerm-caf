output "network_security_perimeter_id" {
  description = "The ID of the network security perimeter."
  value       = azapi_resource.networkSecurityPerimeter.id
}

output "id" {
  description = "The ID of the network security perimeter."
  value       = azapi_resource.networkSecurityPerimeter.id
}

output "profiles" {
  description = "The profiles created in the perimeter, indexed by configuration key."
  value       = azapi_resource.profiles
}

output "access_rules" {
  description = "The access rules created in the perimeter, indexed by configuration key."
  value       = azapi_resource.accessRules
}

output "resource_associations" {
  description = "The PaaS resource associations, indexed by configuration key."
  value       = azapi_resource.resourceAssociations
}

output "links" {
  description = "The perimeter links, indexed by configuration key."
  value       = azapi_resource.links
}

output "link_references" {
  description = "Existing Azure-created link references, indexed by configuration key."
  value       = data.azapi_resource.linkReferences
}

output "logging_configurations" {
  description = "The perimeter logging configurations, indexed by configuration key."
  value       = azapi_resource.loggingConfigurations
}
