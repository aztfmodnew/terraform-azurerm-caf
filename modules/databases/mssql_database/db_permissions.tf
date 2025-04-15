resource "null_resource" "set_db_permissions" {
  for_each = local.db_permissions

  triggers = {
    db_usernames = join(",", each.value.db_usernames)
    db_roles     = join(",", each.value.db_roles)
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/set_db_permissions.sh", path.module)
    interpreter = ["/bin/bash"]
    on_failure  = fail

    environment = {
      SQLCMDSERVER = local.server_name
      SQLCMDDBNAME = azurerm_mssql_database.mssqldb.name
      DBUSERNAMES  = format("'%s'", join(",", each.value.db_usernames))
      DBROLES      = format("'%s'", join(",", each.value.db_roles))
      SQLFILEPATH  = format("%s/scripts/set_db_permissions.sql", path.module)
    }
  }

}

# Set permissions with Microsoft Entra integrated authentication, for demo purposes
resource "null_resource" "set_db_permissions_with_logged_in" {
  # This is a workaround to set permissions with Microsoft Entra integrated authentication
  # The script is executed with the identity of the user who runs Terraform
  # This is not recommended for production use, as it requires the user to have permissions
  for_each = local.db_permissions_with_logged_in

  triggers = {
    db_usernames = join(",", each.value.db_usernames)
    db_roles     = join(",", each.value.db_roles)
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/set_db_permissions_with_logged_in.sh", path.module)
    interpreter = ["/bin/bash"]
    on_failure  = fail

    environment = {
      SQLCMDSERVER = local.server_name
      SQLCMDDBNAME = azurerm_mssql_database.mssqldb.name
      DBUSERNAMES  = format("'%s'", join(",", each.value.db_usernames))
      DBROLES      = format("'%s'", join(",", each.value.db_roles))
      SQLFILEPATH  = format("%s/scripts/set_db_permissions_with_logged_in.sql", path.module)
    }
  }

}