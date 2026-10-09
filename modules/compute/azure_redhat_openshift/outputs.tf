output "name" {
  value       = azapi_resource.aro.name
  description = "Specifies the name of the managed environment."
}

output "id" {
  value       = azapi_resource.aro.id
  description = "Specifies the resource id of the managed environment."
}

output "identity" {
  value       = azapi_resource.aro.identity
  description = "Managed identity metadata for the OpenShift cluster."
}

output "api_server_profile" {
  value       = try(azapi_resource.aro.output.properties.apiserverProfile, null)
  description = "API server endpoint and visibility returned by Azure."
}

output "console_profile" {
  value       = try(azapi_resource.aro.output.properties.consoleProfile, null)
  description = "Console endpoint returned by Azure."
}

output "ingress_profiles" {
  value       = try(azapi_resource.aro.output.properties.ingressProfiles, null)
  description = "Ingress endpoints and visibility returned by Azure."
}
