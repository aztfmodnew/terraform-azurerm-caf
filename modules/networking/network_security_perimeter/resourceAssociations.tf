resource "azapi_resource" "resourceAssociations" {
  for_each  = try(var.settings.resource_associations, {})
  type      = "Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01"
  name      = each.value.name
  parent_id = coalesce(try(each.value.network_security_perimeter_id, null), azapi_resource.networkSecurityPerimeter.id)

  body = {
    properties = {
      accessMode = each.value.access_mode
      privateLinkResource = {
        id = coalesce(
          try(each.value.private_link_resource_id, null),
          try(var.remote_objects.storage_accounts[coalesce(try(each.value.storage_account.lz_key, null), var.client_config.landingzone_key)][each.value.storage_account.key].id, null),
          try(var.remote_objects.keyvaults[coalesce(try(each.value.keyvault.lz_key, null), var.client_config.landingzone_key)][each.value.keyvault.key].id, null),
          try(var.remote_objects.event_hubs[coalesce(try(each.value.event_hub.lz_key, null), var.client_config.landingzone_key)][each.value.event_hub.key].id, null),
          try(var.remote_objects.event_hub_namespaces[coalesce(try(each.value.event_hub_namespace.lz_key, null), var.client_config.landingzone_key)][each.value.event_hub_namespace.key].id, null),
          try(var.remote_objects.cosmos_dbs[coalesce(try(each.value.cosmos_db.lz_key, null), var.client_config.landingzone_key)][each.value.cosmos_db.key].id, null),
          try(var.remote_objects.mssql_servers[coalesce(try(each.value.mssql_server.lz_key, null), var.client_config.landingzone_key)][each.value.mssql_server.key].id, null)
        )
      }
      profile = {
        id = coalesce(try(each.value.profile_id, null), try(azapi_resource.profiles[each.value.profile_key].id, null))
      }
    }
  }

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