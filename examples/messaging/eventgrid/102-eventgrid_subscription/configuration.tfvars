global_settings = {
  default_region = "region1"
  random_length  = 5
  regions = {
    region1 = "southeastasia"
  }
}

resource_groups = {
  # Default to var.global_settings.default_region. You can overwrite it by setting the attribute region = "region2"
  rg1 = {
    name   = "eventgrid"
    region = "region1"
  }
}

storage_accounts = {
  sa1 = {
    name                     = "sa1dev"
    resource_group_key       = "rg1"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    tags = {
      environment = "dev"
      team        = "IT"
    }
  }
}

storage_account_queues = {
  samplequeue = {
    name                = "samplequeuename"
    storage_account_key = "sa1"
  }
}

eventgrid_event_subscription = {
  egs1 = {
    name = "defaultEventSubscription"
    scope = {
      resource_type = "resource_groups"
      key           = "rg1"
    }

    storage_queue_endpoint = {
      storage_account = {
        key = "sa1"
      }
      queue = {
        key = "samplequeue"
      }
    }
  }
  eventhub = {
    name = "eventhub-delivery"
    scope = {
      resource_type = "resource_groups"
      key           = "rg1"
    }
    eventhub = { key = "delivery" }
  }
}
event_hub_namespaces = {
  delivery = {
    name               = "delivery"
    resource_group_key = "rg1"
    region             = "region1"
    sku                = "Standard"
  }
}
event_hubs = {
  delivery = {
    name                    = "delivery"
    event_hub_namespace_key = "delivery"
    resource_group_key      = "rg1"
    partition_count         = 2
    message_retention       = 1
  }
}
eventgrid_system_topic = {
  storage = {
    name            = "storage-events"
    region          = "region1"
    resource_group  = { key = "rg1" }
    topic_type      = "Microsoft.Storage.StorageAccounts"
    source_resource = { type = "storage_accounts", key = "sa1" }
  }
}
eventgrid_system_event_subscription = {
  delivery = {
    name                   = "system-eventhub-delivery"
    resource_group         = { key = "rg1" }
    eventgrid_system_topic = { key = "storage" }
    eventhub               = { key = "delivery" }
  }
}
