resource "azapi_resource" "workspaces" {
  for_each = local.workspaces

  type      = "Microsoft.ApiCenter/services/workspaces@2024-03-01"
  name      = azurecaf_name.workspaces[each.key].result
  parent_id = local.service_id

  body = {
    properties = merge(
      { title = each.value.title },
      try(each.value.description, null) == null ? {} : {
        description = each.value.description
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

resource "azapi_resource" "environments" {
  for_each = local.environments

  type      = "Microsoft.ApiCenter/services/workspaces/environments@2024-03-01"
  name      = azurecaf_name.environments[each.key].result
  parent_id = azapi_resource.workspaces[each.value.workspace_key].id

  body = {
    properties = merge(
      {
        title = each.value.title
        kind  = each.value.kind
      },
      try(each.value.description, null) == null ? {} : { description = each.value.description },
      try(each.value.server, null) == null ? {} : {
        server = merge(
          try(each.value.server.type, null) == null ? {} : { type = each.value.server.type },
          try(each.value.server.management_portal_uri, null) == null && try(each.value.server.management_portal_uris, null) == null ? {} : {
            managementPortalUri = try(
              each.value.server.management_portal_uri != null ? [each.value.server.management_portal_uri] : each.value.server.management_portal_uris,
              null
            )
          }
        )
      },
      try(each.value.onboarding, null) == null ? {} : {
        onboarding = merge(
          try(each.value.onboarding.instructions, null) == null ? {} : { instructions = each.value.onboarding.instructions },
          try(each.value.onboarding.developer_portal_uri, null) == null && try(each.value.onboarding.developer_portal_uris, null) == null ? {} : {
            developerPortalUri = try(
              each.value.onboarding.developer_portal_uri != null ? [each.value.onboarding.developer_portal_uri] : each.value.onboarding.developer_portal_uris,
              null
            )
          }
        )
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

resource "azapi_resource" "apis" {
  for_each = local.apis

  type      = "Microsoft.ApiCenter/services/workspaces/apis@2024-03-01"
  name      = azurecaf_name.apis[each.key].result
  parent_id = azapi_resource.workspaces[each.value.workspace_key].id

  body = {
    properties = merge(
      {
        title = each.value.title
        kind  = each.value.kind
      },
      try(each.value.description, null) == null ? {} : { description = each.value.description },
      try(each.value.summary, null) == null ? {} : { summary = each.value.summary },
      try(each.value.terms_of_service, null) == null ? {} : {
        termsOfService = { url = each.value.terms_of_service.url }
      },
      try(each.value.external_documentation, null) == null ? {} : {
        externalDocumentation = [
          for item in each.value.external_documentation : merge(
            { url = item.url },
            try(item.title, null) == null ? {} : { title = item.title },
            try(item.description, null) == null ? {} : { description = item.description }
          )
        ]
      },
      try(each.value.contacts, null) == null ? {} : {
        contacts = [
          for item in each.value.contacts : merge(
            try(item.name, null) == null ? {} : { name = item.name },
            try(item.url, null) == null ? {} : { url = item.url },
            try(item.email, null) == null ? {} : { email = item.email }
          )
        ]
      },
      try(each.value.license, null) == null ? {} : {
        license = merge(
          try(each.value.license.name, null) == null ? {} : { name = each.value.license.name },
          try(each.value.license.url, null) == null ? {} : { url = each.value.license.url },
          try(each.value.license.identifier, null) == null ? {} : { identifier = each.value.license.identifier }
        )
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
