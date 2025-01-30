storage_accounts = {
  sa1 = {
    name               = "funapp-sa1"
    resource_group_key = "test_re1"
    region             = "region1"

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"

    containers = {
      dev = {
        name = "random"
      }
    }

  }
}