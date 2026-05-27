locals {
  server_fqdn = azurerm_postgresql_flexible_server.postgresql.fqdn

  db_permissions = {
    for group_key, group in try(var.settings.db_permissions, {}) : group_key => {
      database   = group.database
      db_roles   = group.db_roles

      db_usernames = distinct(compact(flatten(concat(
        [
          for mi_key, mi_value in try(group, {}) : [
            for k in try(mi_value.keys, mi_value.managed_identity_keys, []) :
            try(
              var.remote_objects.managed_identities[try(mi_value.lz_key, var.client_config.landingzone_key)][k].name,
              null
            )
          ] if mi_key == "managed_identities"
        ],
        [
          for aad_key, aad_value in try(group, {}) : [
            for k in try(aad_value.keys, []) :
            try(
              var.remote_objects.azuread_groups[try(aad_value.lz_key, var.client_config.landingzone_key)][k].display_name,
              null
            )
          ] if aad_key == "azuread_groups"
        ]
      ))))
    }
  }
}
