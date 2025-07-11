storage_accounts = {
  sa1 = {
    name               = "winfunappprivsa"
    resource_group_key = "funapp"
    region             = "region1"

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"

    # Disable public access for security
    public_network_access_enabled = false

    # Enable hierarchical namespace for better performance
    is_hns_enabled = false

    containers = {
      functions = {
        name = "azure-webjobs-hosts"
      }
      deployments = {
        name = "deployments"
      }
    }

    tags = {
      purpose = "function-app-storage"
    }
  }
}