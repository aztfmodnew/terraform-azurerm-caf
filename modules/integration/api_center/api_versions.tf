resource "azapi_resource" "api_versions" {
  for_each = local.api_versions

  type      = "Microsoft.ApiCenter/services/workspaces/apis/versions@2024-03-01"
  name      = azurecaf_name.api_versions[each.key].result
  parent_id = azapi_resource.apis[each.value.api_key].id

  body = {
    properties = {
      title          = each.value.title
      lifecycleStage = each.value.lifecycle_stage
    }
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

resource "azapi_resource" "definitions" {
  for_each = local.definitions

  type      = "Microsoft.ApiCenter/services/workspaces/apis/versions/definitions@2024-03-01"
  name      = azurecaf_name.definitions[each.key].result
  parent_id = azapi_resource.api_versions[each.value.version_key].id

  body = {
    properties = merge(
      { title = each.value.title },
      try(each.value.description, null) == null ? {} : { description = each.value.description }
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

resource "azapi_resource_action" "import_specification" {
  for_each = {
    for key, definition in local.definitions : key => definition
    if try(definition.specification, null) != null
  }

  type        = "Microsoft.ApiCenter/services/workspaces/apis/versions/definitions@2024-03-01"
  resource_id = azapi_resource.definitions[each.key].id
  action      = "importSpecification"
  method      = "POST"

  body = merge(
    {
      value  = each.value.specification.value
      format = try(each.value.specification.format, "inline")
    },
    try(each.value.specification.name, null) == null && try(each.value.specification.version, null) == null ? {} : {
      specification = merge(
        try(each.value.specification.name, null) == null ? {} : { name = each.value.specification.name },
        try(each.value.specification.version, null) == null ? {} : { version = each.value.specification.version }
      )
    }
  )

  dynamic "timeouts" {
    for_each = try(each.value.specification.timeouts, null) == null ? [] : [each.value.specification.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
