# This file contains the configuration for the managed identities
# used in the example.
managed_identities = {
  # This is the managed identity that will be used to access the
  # mssql server
  webapp_mi = {
    name               = "example_db_mi"
    resource_group_key = "rg1"
  }
}
