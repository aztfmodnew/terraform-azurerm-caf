mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-logger" }
  }
}

run "logger_resolves_eventhub_and_managed_identity_references" {
  command = plan

  module {
    source = "../modules/apim/api_management_logger"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config = { landingzone_key = "local" }
    remote_objects = {
      event_hub_namespaces = {
        local = {
          gateway = {
            id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/gateway"
            name = "gateway"
          }
        }
      }
      event_hubs = {
        local = {
          telemetry = {
            id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/gateway/eventhubs/telemetry"
            name = "telemetry"
          }
        }
      }
      event_hub_auth_rules = {
        local = {
          sender = {
            primary_connection_string = "Endpoint=sb://gateway.servicebus.windows.net/;SharedAccessKeyName=sender;SharedAccessKey=secret;EntityPath=telemetry"
          }
        }
      }
      managed_identities = {
        local = {
          apim = {
            client_id = "00000000-0000-0000-0000-000000000010"
          }
        }
      }
    }
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "eventhub-references"
      eventhub = {
        event_hub_namespace = { key = "gateway" }
        event_hub           = { key = "telemetry" }
        event_hub_authorization_rule = {
          key = "sender"
        }
        managed_identity = { key = "apim" }
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_logger.apim.eventhub[0].name == "telemetry" &&
      nonsensitive(azurerm_api_management_logger.apim.eventhub[0].connection_string) == "Endpoint=sb://gateway.servicebus.windows.net/;SharedAccessKeyName=sender;SharedAccessKey=secret;EntityPath=telemetry" &&
      azurerm_api_management_logger.apim.eventhub[0].endpoint_uri == null &&
      azurerm_api_management_logger.apim.eventhub[0].user_assigned_identity_client_id == null &&
      azurerm_api_management_logger.apim.resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/gateway/eventhubs/telemetry"
    )
    error_message = "The logger must resolve Event Hub namespace, hub, authorization rule, resource ID, and managed identity references."
  }
}

run "logger_resolves_eventhub_managed_identity_ingestion" {
  command = plan

  module {
    source = "../modules/apim/api_management_logger"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      event_hub_namespaces = {
        local = {
          gateway = {
            name = "gateway"
          }
        }
      }
      event_hubs = {
        local = {
          telemetry = {
            name = "telemetry"
          }
        }
      }
      managed_identities = {
        local = {
          apim = {
            client_id = "00000000-0000-0000-0000-000000000010"
          }
        }
      }
    }
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "eventhub-identity-references"
      eventhub = {
        event_hub_namespace = { key = "gateway" }
        event_hub           = { key = "telemetry" }
        managed_identity    = { key = "apim" }
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_logger.apim.eventhub[0].connection_string == null &&
      azurerm_api_management_logger.apim.eventhub[0].endpoint_uri == "https://gateway.servicebus.windows.net:443/" &&
      azurerm_api_management_logger.apim.eventhub[0].user_assigned_identity_client_id == "00000000-0000-0000-0000-000000000010"
    )
    error_message = "Namespace, hub, and managed-identity references must resolve to identity-based Event Hub ingestion."
  }
}

run "logger_direct_eventhub_values_take_precedence" {
  command = plan

  module {
    source = "../modules/apim/api_management_logger"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "eventhub-direct"
      eventhub = {
        name              = "direct-hub"
        connection_string = "Endpoint=sb://direct.servicebus.windows.net/;SharedAccessKeyName=send;SharedAccessKey=secret"
        resource_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/direct/eventhubs/direct-hub"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_logger.apim.eventhub[0].name == "direct-hub" &&
      nonsensitive(azurerm_api_management_logger.apim.eventhub[0].connection_string) == "Endpoint=sb://direct.servicebus.windows.net/;SharedAccessKeyName=send;SharedAccessKey=secret" &&
      azurerm_api_management_logger.apim.eventhub[0].endpoint_uri == null
    )
    error_message = "Legacy direct Event Hub logger inputs must remain unchanged."
  }
}
