output "id" {
  description = "API Center service resource ID."
  value       = local.service_id
}

output "properties" {
  description = "Read-only service properties, including provisioning state."
  value       = local.create_service ? try(azapi_resource.service[0].output.properties, null) : try(local.referenced_service.properties, null)
}

output "name" {
  description = "API Center service name."
  value       = local.create_service ? azurecaf_name.service[0].result : try(split("/", local.service_id)[length(split("/", local.service_id)) - 1], null)
}

output "location" {
  description = "API Center service location when this module creates the service."
  value       = local.create_service ? local.location : try(local.referenced_service.location, null)
}

output "identity" {
  description = "System- or user-assigned identity response for a created service."
  value       = local.create_service ? try(azapi_resource.service[0].output.identity, null) : try(local.referenced_service.identity, null)
}

output "workspaces" {
  description = "Workspace IDs and metadata keyed by nested business key."
  value = {
    for key, resource in azapi_resource.workspaces : key => {
      id         = resource.id
      name       = azurecaf_name.workspaces[key].result
      properties = try(resource.output.properties, null)
    }
  }
}

output "environments" {
  description = "Environment IDs and metadata keyed by workspace/environment."
  value = {
    for key, resource in azapi_resource.environments : key => {
      id         = resource.id
      name       = azurecaf_name.environments[key].result
      properties = try(resource.output.properties, null)
    }
  }
}

output "apis" {
  description = "API IDs and metadata keyed by workspace/API."
  value = {
    for key, resource in azapi_resource.apis : key => {
      id         = resource.id
      name       = azurecaf_name.apis[key].result
      properties = try(resource.output.properties, null)
    }
  }
}

output "api_versions" {
  description = "API version IDs keyed by workspace/API/version."
  value = {
    for key, resource in azapi_resource.api_versions : key => {
      id         = resource.id
      name       = azurecaf_name.api_versions[key].result
      properties = try(resource.output.properties, null)
    }
  }
}

output "definitions" {
  description = "API definition IDs keyed by workspace/API/version/definition."
  value = {
    for key, resource in azapi_resource.definitions : key => {
      id         = resource.id
      name       = azurecaf_name.definitions[key].result
      properties = try(resource.output.properties, null)
    }
  }
}

output "deployments" {
  description = "API deployment IDs keyed by workspace/API/deployment."
  value = {
    for key, resource in azapi_resource.deployments : key => {
      id         = resource.id
      name       = azurecaf_name.deployments[key].result
      properties = try(resource.output.properties, null)
    }
  }
}

output "metadata_schemas" {
  description = "Metadata schema IDs keyed by schema business key."
  value = {
    for key, resource in azapi_resource.metadata_schemas : key => {
      id         = resource.id
      name       = azurecaf_name.metadata_schemas[key].result
      properties = try(resource.output.properties, null)
    }
  }
}
