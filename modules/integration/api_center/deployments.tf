resource "azapi_resource" "deployments" {
  for_each = local.deployments

  type      = "Microsoft.ApiCenter/services/workspaces/apis/deployments@2024-03-01"
  name      = azurecaf_name.deployments[each.key].result
  parent_id = azapi_resource.apis[each.value.api_key].id

  body = {
    properties = merge(
      try(each.value.title, null) == null ? {} : { title = each.value.title },
      try(each.value.description, null) == null ? {} : { description = each.value.description },
      try(each.value.environment_id, null) == null && try(each.value.environment, null) == null ? {} : {
        environmentId = coalesce(
          try(replace(each.value.environment_id, "/^.*\\/providers\\/Microsoft\\.ApiCenter\\/services\\/[^/]+\\//", ""), null),
          try(replace(each.value.environment.id, "/^.*\\/providers\\/Microsoft\\.ApiCenter\\/services\\/[^/]+\\//", ""), null),
          try(replace(azapi_resource.environments["${each.value.workspace_key}/${each.value.environment.key}"].id, "/^.*\\/providers\\/Microsoft\\.ApiCenter\\/services\\/[^/]+\\//", ""), null)
        )
      },
      try(each.value.definition_id, null) == null && try(each.value.definition, null) == null ? {} : {
        definitionId = coalesce(
          try(replace(each.value.definition_id, "/^.*\\/providers\\/Microsoft\\.ApiCenter\\/services\\/[^/]+\\//", ""), null),
          try(replace(each.value.definition.id, "/^.*\\/providers\\/Microsoft\\.ApiCenter\\/services\\/[^/]+\\//", ""), null),
          try(replace(azapi_resource.definitions["${each.value.api_key}/${each.value.definition.version_key}/${each.value.definition.key}"].id, "/^.*\\/providers\\/Microsoft\\.ApiCenter\\/services\\/[^/]+\\//", ""), null)
        )
      },
      try(each.value.state, null) == null ? {} : { state = each.value.state },
      try(each.value.server, null) == null ? {} : {
        server = {
          runtimeUri = each.value.server.runtime_uris
        }
      },
      try(each.value.custom_properties, null) == null ? {} : { customProperties = each.value.custom_properties }
    )
  }

  response_export_values = ["properties"]

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
