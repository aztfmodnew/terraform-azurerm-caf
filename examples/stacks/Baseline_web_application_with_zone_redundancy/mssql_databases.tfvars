mssql_databases = {

  mssql_db1 = {
    name               = "adventureworks"
    resource_group_key = "rg1"
    mssql_server_key   = "adventureworks-rg1"
    license_type       = "LicenseIncluded"
    max_size_gb        = 4
    sku_name           = "BC_Gen5_2"
    sample_name        = "AdventureWorksLT"

    # Only works with SystemAssigned MSI, logged_in users will not be able to provision the db_permission for now.
    /*db_permissions_with_logged_in = {
      group1 = { # group_name
        db_roles = ["db_owner", "db_accessadmin"]
        managed_identities = {
          examples = { # lz_key
            managed_identity_keys = ["webapp_mi"]
          }
          # remote_mi = {
          #   managed_identity_keys = ["mi1"]
          # }
        }
      }
    }*/

  }
}