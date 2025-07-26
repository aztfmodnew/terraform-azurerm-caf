global_settings = {
  default_region = "region1"
  environment    = "dev"
  prefix         = "caf"
  suffix         = "queue"

  regions = {
    region1 = "australiaeast"
  }

  inherit_tags = true

  # Hybrid naming configuration - using azurecaf (default)
  naming = {
    use_azurecaf     = true
    use_local_module = false
  }
}

resource_groups = {
  test = {
    name = "test"
  }
}

#Storage Queue requires a Storage Account to reference
storage_accounts = {
  sa1 = {
    name                     = "sa1dev"
    resource_group_key       = "test"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS" # https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy
    tags = {
      environment = "dev"
      team        = "IT"
    }
  }
}

# Be sure to declare the Storage Account Queue outside of the Storage Account object
storage_account_queues = {
  samplequeue = {
    name                = "samplequeuename"
    storage_account_key = "sa1"
  }
}
