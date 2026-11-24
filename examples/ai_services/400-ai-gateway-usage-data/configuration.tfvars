global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  usage_data = {
    name = "ai-gateway-usage-data"
  }
}

log_analytics = {
  usage_data = {
    name               = "ai-gateway-usage"
    resource_group_key = "usage_data"
    sku                = "PerGB2018"
    retention_in_days  = 30
  }
}

azurerm_application_insights = {
  usage_data = {
    name               = "ai-gateway-usage"
    resource_group_key = "usage_data"
    application_type   = "web"
    log_analytics_workspace = {
      key = "usage_data"
    }
  }
}

event_hub_namespaces = {
  usage_data = {
    name                          = "ai-gateway-usage"
    resource_group_key            = "usage_data"
    sku                           = "Standard"
    region                        = "region1"
    local_authentication_enabled  = false
    public_network_access_enabled = true
    minimum_tls_version           = "1.2"
  }
}

event_hubs = {
  usage_events = {
    name                    = "usage-events"
    resource_group_key      = "usage_data"
    event_hub_namespace_key = "usage_data"
    partition_count         = 4
    message_retention       = 1
  }
}

event_hub_consumer_groups = {
  usage_processors = {
    name                    = "usage-processors"
    resource_group_key      = "usage_data"
    event_hub_namespace_key = "usage_data"
    event_hub_name_key      = "usage_events"
  }
}

storage_accounts = {
  logic_app_runtime = {
    name                     = "aigwusage"
    resource_group_key       = "usage_data"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    min_tls_version          = "TLS1_2"
  }
}

service_plans = {
  usage_processor = {
    name               = "ai-gateway-usage"
    resource_group_key = "usage_data"
    os_type            = "Windows"
    sku_name           = "WS1"
  }
}

cosmos_dbs = {
  usage_data = {
    name                         = "ai-gateway-usage"
    resource_group_key           = "usage_data"
    offer_type                   = "Standard"
    kind                         = "GlobalDocumentDB"
    automatic_failover_enabled   = true
    local_authentication_enabled = false

    consistency_policy = {
      consistency_level = "Session"
    }

    geo_locations = {
      primary = {
        region            = "region1"
        failover_priority = 0
        zone_redundant    = false
      }
    }

    sql_databases = {
      usage = {
        name       = "ai-gateway-usage"
        throughput = 400
        containers = {
          usage_records = {
            name                  = "usage-records"
            partition_key_paths   = ["/tenantId"]
            partition_key_version = 2
            default_ttl           = 2592000
          }
          usage_rollups = {
            name                  = "usage-rollups"
            partition_key_paths   = ["/tenantId"]
            partition_key_version = 2
            default_ttl           = 31536000
          }
        }
      }
    }

    diagnostic_profiles = {
      operations = {
        name                           = "ai-gateway-usage-cosmos"
        definition_key                 = "cosmosdb_usage"
        destination_type               = ["log_analytics"]
        destination_key                = "usage_data"
        log_analytics_destination_type = "Dedicated"
      }
    }

    timeouts = {
      create = "90m"
      update = "90m"
      delete = "90m"
    }
  }
}

logic_app_standard = {
  usage_processor = {
    name                = "ai-gateway-usage-processor"
    resource_group_key  = "usage_data"
    service_plan_key    = "usage_processor"
    storage_account_key = "logic_app_runtime"
    version             = "~4"
    https_only          = true

    identity = {
      type = "SystemAssigned"
    }

    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "node"
      COSMOS_DATABASE_NAME     = "ai-gateway-usage"
      USAGE_RECORDS_CONTAINER  = "usage-records"
      USAGE_ROLLUPS_CONTAINER  = "usage-rollups"
    }

    dynamic_app_settings = {
      COSMOS_ACCOUNT_ENDPOINT = {
        cosmos_dbs = {
          usage_data = {
            attribute_key = "endpoint"
          }
        }
      }
      EVENT_HUB_NAMESPACE_NAME = {
        event_hub_namespaces = {
          usage_data = {
            attribute_key = "name"
          }
        }
      }
      EVENT_HUB_NAME = {
        event_hubs = {
          usage_events = {
            attribute_key = "name"
          }
        }
      }
      LOG_ANALYTICS_WORKSPACE_ID = {
        log_analytics = {
          usage_data = {
            attribute_key = "workspace_id"
          }
        }
      }
      APPLICATIONINSIGHTS_CONNECTION_STRING = {
        azurerm_application_insights = {
          usage_data = {
            attribute_key = "connection_string"
          }
        }
      }
    }

    diagnostic_profiles = {
      operations = {
        name                           = "ai-gateway-usage-logic-app"
        definition_key                 = "logic_app_usage"
        destination_type               = ["log_analytics"]
        destination_key                = "usage_data"
        log_analytics_destination_type = "Dedicated"
      }
    }

    timeouts = {
      create = "60m"
      update = "60m"
      delete = "60m"
    }
  }
}

diagnostics_definition = {
  cosmosdb_usage = {
    name = "ai-gateway-usage-cosmos"
    categories = {
      log = [
        ["DataPlaneRequests", true, false, 0],
      ]
      metric = [
        ["Requests", true, false, 0],
      ]
    }
  }
  logic_app_usage = {
    name = "ai-gateway-usage-logic-app"
    categories = {
      metric = [
        ["AllMetrics", true, false, 0],
      ]
    }
  }
}

diagnostics_destinations = {
  log_analytics = {
    usage_data = {
      log_analytics_key = "usage_data"
    }
  }
}

role_mapping = {
  built_in_role_mapping = {
    event_hub_namespaces = {
      usage_data = {
        "Azure Event Hubs Data Receiver" = {
          logic_app_standard = {
            keys = ["usage_processor"]
          }
        }
      }
    }
    storage_accounts = {
      logic_app_runtime = {
        "Storage Blob Data Contributor" = {
          logic_app_standard = {
            keys = ["usage_processor"]
          }
        }
        "Storage Queue Data Contributor" = {
          logic_app_standard = {
            keys = ["usage_processor"]
          }
        }
      }
    }
  }
}

cosmosdb_role_mapping = {
  built_in_role_mapping = {
    cosmosdb_accounts = {
      usage_data = {
        "Cosmos DB Built-in Data Contributor" = {
          logic_app_standard = {
            keys               = ["usage_processor"]
            resource_group_key = "usage_data"
          }
        }
      }
    }
  }
}
