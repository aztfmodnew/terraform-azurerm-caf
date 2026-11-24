global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 4
}

resource_groups = {
  ai_gateway = {
    name = "ai-gateway-observability"
  }
}

managed_identities = {
  ai_gateway = {
    name               = "ai-gateway"
    resource_group_key = "ai_gateway"
  }
}

log_analytics = {
  ai_gateway = {
    name                            = "ai-gateway"
    resource_group_key              = "ai_gateway"
    region                          = "region1"
    sku                             = "PerGB2018"
    retention_in_days               = 30
    allow_resource_only_permissions = true
    local_authentication_enabled    = true
    timeouts = {
      create = "45m"
      update = "45m"
    }
  }
}

event_hub_namespaces = {
  ai_gateway = {
    name                          = "ai-gateway"
    resource_group_key            = "ai_gateway"
    region                        = "region1"
    sku                           = "Standard"
    local_authentication_enabled  = false
    public_network_access_enabled = true
    minimum_tls_version           = "1.2"

    network_rulesets = {
      default_action                = "Allow"
      public_network_access_enabled = true
    }
  }
}

event_hubs = {
  gateway_telemetry = {
    name                    = "gateway-telemetry"
    resource_group_key      = "ai_gateway"
    event_hub_namespace_key = "ai_gateway"
    partition_count         = 4
    message_retention       = 1
  }
}

api_management = {
  ai_gateway = {
    name            = "ai-gateway"
    region          = "region1"
    publisher_name  = "AI Gateway"
    publisher_email = "owner@example.com"
    sku_name        = "Developer_1"
    resource_group = {
      key = "ai_gateway"
    }
    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["ai_gateway"]
    }
    diagnostic_profiles = {
      platform = {
        name                           = "ai-gateway-platform"
        definition_key                 = "api_management"
        destination_type               = ["log_analytics"]
        destination_key                = "ai_gateway"
        log_analytics_destination_type = "Dedicated"
      }
    }
  }
}

api_management_api = {
  ai_gateway = {
    name = "ai-gateway"
    resource_group = {
      key = "ai_gateway"
    }
    api_management = {
      key = "ai_gateway"
    }
    revision     = "1"
    display_name = "AI Gateway"
    path         = "ai"
    protocols    = ["https"]
    service_url  = "https://example.invalid"
  }
}

api_management_logger = {
  eventhub = {
    name        = "ai-gateway-events"
    description = "AI Gateway request telemetry"
    resource_group = {
      key = "ai_gateway"
    }
    api_management = {
      key = "ai_gateway"
    }
    eventhub = {
      event_hub_namespace = {
        key = "ai_gateway"
      }
      event_hub = {
        key = "gateway_telemetry"
      }
      managed_identity = {
        key = "ai_gateway"
      }
    }
  }
}

api_management_diagnostic = {
  service = {
    identifier = "azuremonitor"
    resource_group = {
      key = "ai_gateway"
    }
    api_management = {
      key = "ai_gateway"
    }
    api_management_logger = {
      key = "eventhub"
    }
    sampling_percentage       = 100
    always_log_errors         = true
    log_client_ip             = false
    http_correlation_protocol = "W3C"
    verbosity                 = "information"
  }
}

api_management_api_diagnostic = {
  api = {
    identifier = "azuremonitor"
    resource_group = {
      key = "ai_gateway"
    }
    api_management = {
      key = "ai_gateway"
    }
    api = {
      key = "ai_gateway"
    }
    api_management_logger = {
      key = "eventhub"
    }
    sampling_percentage       = 100
    always_log_errors         = true
    log_client_ip             = false
    http_correlation_protocol = "W3C"
    verbosity                 = "information"
  }
}

diagnostics_definition = {
  api_management = {
    name = "ai-gateway-platform"
    categories = {
      log = [
        ["GatewayLogs", true, false, 0],
      ]
      metric = [
        ["AllMetrics", true, false, 0],
      ]
    }
  }
}

diagnostics_destinations = {
  log_analytics = {
    ai_gateway = {
      log_analytics_key = "ai_gateway"
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
