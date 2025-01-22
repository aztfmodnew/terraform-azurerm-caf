resource "azapi_resource" "resourceAssociations" {
  for_each  = try(var.settings.resource_associations, {})
  type      = "Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2023-08-01-preview"
  name      = each.value.name
  parent_id = coalesce(try(each.value.network_security_perimeter_id, null), azapi_resource.networkSecurityPerimeter.id)
  location  = coalesce(try(each.value.location, null), var.resource_group.location)

  body = {
    properties = {
      accessMode = each.value.access_mode
      privateLinkResource = {
        id = coalesce(try(each.value.private_link_resource_id, null), try(var.remote_objects.storage_accounts[try(each.value.storage_account.lz_key, var.client_config.landingzone_key)][each.value.storage_account.key].id, null), try(var.remote_objects.keyvaults[try(each.value.keyvault.lz_key, var.client_config.landingzone_key)][each.value.keyvault.key].id, null), try(var.remote_objects.event_hubs[try(each.value.event_hub.lz_key, var.client_config.landingzone_key)][each.value.event_hub.key].id, null), try(var.remote_objects.cosmos_dbs[try(each.value.cosmos_db.lz_key, var.client_config.landingzone_key)][each.value.cosmos_db.key].id, null), try(var.remote_objects.mssql_servers[try(each.value.mssql_server.lz_key, var.client_config.landingzone_key)][each.value.mssql_server.key].id, null)
        )
      }
      profile = {
        id = azapi_resource.profiles[each.value.profile_key].id
      }
    }
  }

  tags = merge(local.tags, try(each.value.tags, {}))
}