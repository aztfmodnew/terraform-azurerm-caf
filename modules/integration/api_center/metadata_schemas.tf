resource "azapi_resource" "metadata_schemas" {
  for_each = local.metadata_schemas

  type      = "Microsoft.ApiCenter/services/metadataSchemas@2024-03-01"
  name      = azurecaf_name.metadata_schemas[each.key].result
  parent_id = local.service_id

  body = {
    properties = merge(
      { schema = each.value.schema },
      try(each.value.assigned_to, null) == null ? {} : {
        assignedTo = [
          for assignment in each.value.assigned_to : merge(
            try(assignment.entity, null) == null ? {} : { entity = assignment.entity },
            try(assignment.required, null) == null ? {} : { required = assignment.required },
            try(assignment.deprecated, null) == null ? {} : { deprecated = assignment.deprecated }
          )
        ]
      }
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
