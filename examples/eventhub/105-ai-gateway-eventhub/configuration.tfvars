global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
}

resource_groups = {
  ai_gateway_eventhub = {
    name = "ai-gateway-eventhub"
  }
}

managed_identities = {
  ai_gateway = {
    name               = "ai-gateway"
    resource_group_key = "ai_gateway_eventhub"
  }
}

event_hub_namespaces = {
  ai_gateway = {
    name                          = "ai-gateway"
    resource_group_key            = "ai_gateway_eventhub"
    sku                           = "Standard"
    region                        = "region1"
    local_authentication_enabled  = false
    public_network_access_enabled = false
    minimum_tls_version           = "1.2"

    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["ai_gateway"]
    }

    network_rulesets = {
      default_action                 = "Deny"
      public_network_access_enabled  = false
      trusted_service_access_enabled = true
    }

    timeouts = {
      create = "45m"
      update = "45m"
      delete = "45m"
    }
  }
}

event_hubs = {
  requests = {
    name                    = "requests"
    resource_group_key      = "ai_gateway_eventhub"
    event_hub_namespace_key = "ai_gateway"
    partition_count         = 4
    retention_description = {
      cleanup_policy          = "Delete"
      retention_time_in_hours = 24
    }
    timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
  }

  responses = {
    name                    = "responses"
    resource_group_key      = "ai_gateway_eventhub"
    event_hub_namespace_key = "ai_gateway"
    partition_count         = 4
    message_retention       = 1
    timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
  }
}

event_hub_consumer_groups = {
  ai_gateway_processors = {
    name                    = "ai-gateway-processors"
    resource_group_key      = "ai_gateway_eventhub"
    event_hub_namespace_key = "ai_gateway"
    event_hub_name_key      = "requests"
    user_metadata           = "AI gateway request processors"
    timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
  }
}

role_mapping = {
  built_in_role_mapping = {
    event_hub_namespaces = {
      ai_gateway = {
        "Azure Event Hubs Data Sender" = {
          managed_identities = {
            keys = ["ai_gateway"]
          }
        }
      }
    }
  }
}
