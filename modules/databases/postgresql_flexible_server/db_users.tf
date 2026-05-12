data "azurerm_key_vault_secret" "postgresql_admin_password" {
  count        = try(var.settings.postgresql_users, null) == null ? 0 : 1
  name         = format("%s-password", azurecaf_name.postgresql_flexible_server.result)
  key_vault_id = try(var.remote_objects.keyvault_id, null)
}

resource "random_password" "pg_user" {
  for_each         = try(var.settings.postgresql_users, {})
  length           = 128
  special          = true
  upper            = true
  numeric          = true
  override_special = "$#%"
}

resource "azurerm_key_vault_secret" "pg_user_password" {
  for_each     = try(var.settings.postgresql_users, {})
  name         = format("%s-%s-%s-password", azurecaf_name.postgresql_flexible_server.result, each.value.database, each.key)
  value        = random_password.pg_user[each.key].result
  key_vault_id = try(var.remote_objects.keyvault_id, null)
  lifecycle {
    ignore_changes = [value]
  }
}

resource "null_resource" "create_pg_user" {
  depends_on = [azurerm_postgresql_flexible_server.postgresql]
  for_each   = try(var.settings.postgresql_users, {})

  provisioner "local-exec" {
    interpreter = ["/bin/bash"]
    on_failure  = fail
    command     = format("%s/scripts/create_pg_user.sh", path.module)
    environment = {
      PGHOST           = local.server_fqdn
      PGPORT           = "5432"
      PGDATABASE       = each.value.database
      DBADMINUSER      = try(var.settings.administrator_username, "pgadmin")
      DBADMINPWD       = try(azurerm_postgresql_flexible_server.postgresql.administrator_password, data.azurerm_key_vault_secret.postgresql_admin_password[0].value)
      DBUSERNAMES      = each.value.name
      DBROLES          = each.value.role
      DBUSERPASSWORDS  = azurerm_key_vault_secret.pg_user_password[each.key].value
      SQLLOGINFILEPATH = format("%s/scripts/create_pg_login.sql", path.module)
      SQLUSERFILEPATH  = format("%s/scripts/create_pg_user.sql", path.module)
    }
  }
}

resource "null_resource" "delete_pg_user" {
  depends_on = [azurerm_postgresql_flexible_server.postgresql]
  for_each   = try(var.settings.postgresql_users, {})
  triggers = {
    pg_server_fqdn     = local.server_fqdn
    pg_server_db_name  = each.value.database
    db_admin_user      = try(var.settings.administrator_username, "pgadmin")
    db_admin_password  = try(azurerm_postgresql_flexible_server.postgresql.administrator_password, data.azurerm_key_vault_secret.postgresql_admin_password[0].value)
    db_user_name       = each.value.name
    pg_login_filepath  = format("%s/scripts/delete_pg_login.sql", path.module)
    pg_user_filepath   = format("%s/scripts/delete_pg_user.sql", path.module)
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash"]
    when        = destroy
    command     = format("%s/scripts/delete_pg_user.sh", path.module)
    on_failure  = fail
    environment = {
      PGHOST           = self.triggers.pg_server_fqdn
      PGPORT           = "5432"
      PGDATABASE       = self.triggers.pg_server_db_name
      DBADMINUSER      = self.triggers.db_admin_user
      DBADMINPWD       = self.triggers.db_admin_password
      DBUSERNAMES      = self.triggers.db_user_name
      SQLLOGINFILEPATH = self.triggers.pg_login_filepath
      SQLUSERFILEPATH  = self.triggers.pg_user_filepath
    }
  }
}
