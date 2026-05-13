resource "null_resource" "set_db_permissions" {
  for_each = local.db_permissions

  triggers = {
    db_usernames = join(",", each.value.db_usernames)
    db_roles     = join(",", each.value.db_roles)
    database     = each.value.database
    server_fqdn  = local.server_fqdn
    admin_user   = try(var.settings.administrator_username, "pgadmin")
    admin_pwd    = try(azurerm_postgresql_flexible_server.postgresql.administrator_password, data.azurerm_key_vault_secret.postgresql_admin_password[0].value)
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/set_db_permissions.sh", path.module)
    interpreter = ["/bin/bash"]
    on_failure  = fail
    environment = {
      PGHOST       = self.triggers.server_fqdn
      PGPORT       = "5432"
      PGDATABASE   = self.triggers.database
      DBADMINUSER  = self.triggers.admin_user
      DBADMINPWD   = self.triggers.admin_pwd
      DBUSERNAMES  = format("'%s'", self.triggers.db_usernames)
      DBROLES      = format("'%s'", self.triggers.db_roles)
      SQLFILEPATH  = format("%s/scripts/set_db_permissions.sql", path.module)
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = format("%s/scripts/revoke_db_permissions.sh", path.module)
    interpreter = ["/bin/bash"]
    on_failure  = continue
    environment = {
      PGHOST      = self.triggers.server_fqdn
      PGPORT      = "5432"
      PGDATABASE  = self.triggers.database
      DBADMINUSER = self.triggers.admin_user
      DBADMINPWD  = self.triggers.admin_pwd
      DBUSERNAMES = self.triggers.db_usernames
    }
  }
}
