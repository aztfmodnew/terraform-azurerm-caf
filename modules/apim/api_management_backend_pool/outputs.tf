output "id" {
  description = "ARM resource ID of the APIM backend pool."
  value       = azapi_resource.resource.id
}
output "name" {
  description = "CAF-compliant APIM backend pool name."
  value       = azurecaf_name.resource.result
}
output "service_ids" {
  description = "Resolved APIM child backend IDs included in the pool."
  value       = [for service in local.services : service.id]
}
output "properties" {
  description = "Normalized ARM backend pool properties returned by AzAPI."
  value       = azapi_resource.resource.output.properties
}
