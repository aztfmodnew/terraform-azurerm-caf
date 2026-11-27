resource "azapi_resource" "service" {
  count = local.create_service ? 1 : 0

  type      = "Microsoft.ApiCenter/services@2024-03-01"
  name      = azurecaf_name.service[0].result
  parent_id = "/subscriptions/${var.client_config.subscription_id}/resourceGroups/${local.resource_group_name}"
  location  = local.location
  tags      = local.tags

  body = merge(
    { properties = {} },
    try(var.settings.identity, null) == null ? {} : {
      identity = merge(
        { type = var.settings.identity.type },
        contains(["UserAssigned", "SystemAssigned,UserAssigned"], var.settings.identity.type) && length(local.identity_ids) > 0 ? {
          userAssignedIdentities = {
            for id in local.identity_ids : id => {}
          }
        } : {}
      )
    }
  )

  response_export_values = ["properties", "identity"]

  lifecycle {
    precondition {
      condition     = local.resource_group_name != null && local.location != null
      error_message = "A creatable API Center service requires a resolvable resource group and location."
    }
    precondition {
      condition     = try(var.settings.identity.type, "None") != "UserAssigned" || length(local.identity_ids) > 0
      error_message = "UserAssigned API Center identities require at least one managed identity ID or key."
    }
    precondition {
      condition     = try(var.settings.identity.type, "None") != "SystemAssigned,UserAssigned" || length(local.identity_ids) > 0
      error_message = "Combined API Center identities require at least one managed identity ID or key."
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
