
diagnostic_storage_accounts = {
  diagnostics_region1 = {
    name                     = "diagrg1"
    resource_group_key       = "front_door"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Cool"
    management_policy = {
      rules = [
        {
          name    = "Diagnostics Settings Retention Rule"
          enabled = true
          filters = {
            prefix_match = ["$logs/FrontDoorWebApplicationFirewallLog", "$logs/FrontDoorAccessLog"]
            blob_types   = ["appendBlob"]

          }
          actions = {
            base_blob = {
              delete_after_days_since_modification_greater_than = 30
            }
          }
        }
      ]
    }
  }
}