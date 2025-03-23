azuread_groups = {
  sqlserver_admin = {
    name        = "example-sqlserver-admins"
    description = "Administrators of the sales SQL server."
    members = {
      user_principal_names = []

      # NOTE: To ensure DB users can be created, sqlserver admin needs to add the rover agent's system assigned identity object ID added
      # NOTE: since the authentication uses SQLCMD + DSN, UID cannot be supplied to the connection string, thus only system assigned identity is possible at this stage.
      object_ids = [
        # Add object id of rover agent with system assigned identity here.
      ]
      group_keys             = []
      service_principal_keys = []
    }
    owners = {
      user_principal_names = [
      ]
      service_principal_keys = []
      object_ids             = [
      ]
    }
    prevent_duplicate_name = false
  }
}