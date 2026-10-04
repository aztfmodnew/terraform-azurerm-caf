global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
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
    queues = {
      nested = {
        name = "nestedqueue"
      }
    }
    queue_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "POST"]
        allowed_origins    = ["https://example.com"]
        exposed_headers    = ["*"]
        max_age_in_seconds = 200
      }
      logging = {
        delete                = true
        read                  = true
        write                 = true
        version               = "1.0"
        retention_policy_days = 7
      }
      minute_metrics = {
        enabled               = false
        version               = "1.0"
        include_apis          = true
        retention_policy_days = 7
      }
      hour_metrics = {
        enabled               = true
        version               = "1.0"
        include_apis          = true
        retention_policy_days = 7
      }
    }
    tags = {
      environment = "dev"
      team        = "IT"
    }
  }
}

# Both nested queues and standalone queues are supported.
storage_account_queues = {
  samplequeue = {
    name                = "samplequeuename"
    storage_account_key = "sa1"
  }
}
