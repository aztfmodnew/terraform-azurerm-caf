locals {
  module_tag = {
    module = basename(abspath(path.module))
  }

  tags = merge(var.base_tags, local.module_tag, try(var.settings.tags, {}))

  resource_group_lz_key = coalesce(try(var.settings.resource_group.lz_key, null), var.client_config.landingzone_key)
  resource_group = try(
    var.remote_objects.resource_groups[local.resource_group_lz_key][var.settings.resource_group.key],
    null
  )
  resource_group_name = try(coalesce(
    try(var.settings.resource_group_name, null),
    try(var.settings.resource_group.name, null),
    try(local.resource_group.name, null)
  ), null)
  location = try(coalesce(
    try(var.settings.location, null),
    try(var.settings.resource_group.location, null),
    try(local.resource_group.location, null),
    try(var.global_settings.regions[var.settings.region], null),
    try(var.global_settings.regions[var.global_settings.default_region], null)
  ), null)

  service_lz_key = coalesce(try(var.settings.service.lz_key, null), var.client_config.landingzone_key)
  referenced_service = try(
    var.remote_objects.api_centers[local.service_lz_key][var.settings.service.key],
    null
  )
  create_service = (
    try(var.settings.service_id, null) == null &&
    try(var.settings.service.id, null) == null &&
    try(local.referenced_service.id, null) == null
  )
  service_id = try(coalesce(
    try(var.settings.service_id, null),
    try(var.settings.service.id, null),
    try(local.referenced_service.id, null),
    try(azapi_resource.service[0].id, null)
  ), null)

  identity_ids = compact(concat(
    try(var.settings.identity.identity_ids, []),
    [
      for reference in try(var.settings.identity.managed_identities, []) :
      coalesce(
        try(reference.id, null),
        try(var.remote_objects.managed_identities[coalesce(try(reference.lz_key, null), var.client_config.landingzone_key)][reference.key].id, null)
      )
    ],
    [
      for key in try(var.settings.identity.managed_identity_keys, []) :
      try(var.remote_objects.managed_identities[var.client_config.landingzone_key][key].id, null)
    ]
  ))

  workspaces = {
    for item in [
      for key, workspace in try(var.settings.workspaces, {}) : merge(workspace, {
        key = key
      })
    ] : item.key => item
  }

  environments = {
    for item in flatten([
      for workspace_key, workspace in local.workspaces : [
        for environment_key, environment in try(workspace.environments, {}) : merge(environment, {
          composite_key = "${workspace_key}/${environment_key}"
          key           = environment_key
          workspace_key = workspace_key
        })
      ]
    ]) : item.composite_key => item
  }

  apis = {
    for item in flatten([
      for workspace_key, workspace in local.workspaces : [
        for api_key, api in try(workspace.apis, {}) : merge(api, {
          composite_key = "${workspace_key}/${api_key}"
          key           = api_key
          workspace_key = workspace_key
        })
      ]
    ]) : item.composite_key => item
  }

  api_versions = {
    for item in flatten([
      for api_composite_key, api in local.apis : [
        for version_key, version in try(api.versions, {}) : merge(version, {
          composite_key = "${api_composite_key}/${version_key}"
          key           = version_key
          api_key       = api_composite_key
        })
      ]
    ]) : item.composite_key => item
  }

  definitions = {
    for item in flatten([
      for version_composite_key, version in local.api_versions : [
        for definition_key, definition in try(version.definitions, {}) : merge(definition, {
          composite_key = "${version_composite_key}/${definition_key}"
          key           = definition_key
          version_key   = version_composite_key
        })
      ]
    ]) : item.composite_key => item
  }

  deployments = {
    for item in flatten([
      for api_composite_key, api in local.apis : [
        for deployment_key, deployment in try(api.deployments, {}) : merge(deployment, {
          composite_key = "${api_composite_key}/${deployment_key}"
          key           = deployment_key
          api_key       = api_composite_key
          workspace_key = api.workspace_key
        })
      ]
    ]) : item.composite_key => item
  }

  metadata_schemas = {
    for item in [
      for key, schema in try(var.settings.metadata_schemas, {}) : merge(schema, {
        key = key
      })
    ] : item.key => item
  }

  arm_names = compact(concat(
    local.create_service ? [try(var.settings.name, null)] : [],
    [for workspace in values(local.workspaces) : workspace.name],
    [for environment in values(local.environments) : environment.name],
    [for api in values(local.apis) : api.name],
    [for version in values(local.api_versions) : version.name],
    [for definition in values(local.definitions) : definition.name],
    [for deployment in values(local.deployments) : deployment.name],
    [for schema in values(local.metadata_schemas) : schema.name]
  ))
}
