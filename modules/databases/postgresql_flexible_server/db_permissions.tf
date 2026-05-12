resource "null_resource" "set_db_permissions" {
  for_each = local.db_permissions

  triggers = {
    db_usernames = join(",", each.value.db_usernames)
    db_roles     = join(",", each.value.db_roles)
    database     = each.value.database
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/set_db_permissions.sh", path.module)
    interpreter = ["/bin/bash"]
    on_failure  = fail
    environment = {
      PGHOST       = local.server_fqdn
      PGPORT       = "5432"
      PGDATABASE   = each.value.database
      DBADMINUSER  = try(var.settings.administrator_username, "pgadmin")
      DBADMINPWD   = try(azurerm_postgresql_flexible_server.postgresql.administrator_password, data.azurerm_key_vault_secret.postgresql_admin_password[0].value)
      DBUSERNAMES  = format("'%s'", join(",", each.value.db_usernames))
      DBROLES      = format("'%s'", join(",", each.value.db_roles))
      SQLFILEPATH  = format("%s/scripts/set_db_permissions.sql", path.module)
    }
  }
}
