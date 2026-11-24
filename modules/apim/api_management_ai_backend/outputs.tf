output "id" {
  description = "ARM resource ID of the APIM AI backend."
  value       = azapi_resource.resource.id
}
output "name" {
  description = "CAF-compliant APIM AI backend name."
  value       = azurecaf_name.resource.result
}
output "url" {
  description = "Normalized HTTPS backend URL, including the optional endpoint path."
  value       = local.endpoint_url
}
output "endpoint" {
  description = "Resolved endpoint before the optional path is appended."
  value       = local.endpoint
}
output "managed_identity_client_id" {
  description = "Resolved user-assigned managed identity client ID, or null for system-assigned identity."
  value       = local.managed_identity_client_id
}
output "managed_identity_name" {
  description = "Resolved managed identity display name, when configured."
  value       = local.managed_identity_name
}
output "authentication_policy" {
  description = "Policy XML fragment; backend ARM bodies do not carry managed-identity credentials."
  value       = local.authentication_policy
}
output "properties" {
  description = "Normalized ARM backend properties returned by AzAPI."
  value       = azapi_resource.resource.output.properties
}
