mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-logger" }
  }
}

run "logger_with_identity_ingestion_and_resource_reference" {
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
      application_insights = {
        local = {
          app = {
            id                  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Insights/components/app"
            instrumentation_key = "00000000-0000-0000-0000-000000000002"
            connection_string   = "InstrumentationKey=00000000-0000-0000-0000-000000000002;IngestionEndpoint=https://example.invalid/"
          }
        }
      }
    }
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name        = "ai-logger"
      buffered    = false
      description = "Identity-authenticated monitoring logger"
      resource    = { key = "app" }
      application_insights = {
        key                = "app"
        identity_client_id = "00000000-0000-0000-0000-000000000003"
      }
      timeouts = {
        create = "45m"
        read   = "6m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_logger.apim.name == "example-logger" &&
      azurerm_api_management_logger.apim.buffered == false &&
      azurerm_api_management_logger.apim.resource_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Insights/components/app" &&
      nonsensitive(azurerm_api_management_logger.apim.application_insights[0].connection_string) == "InstrumentationKey=00000000-0000-0000-0000-000000000002;IngestionEndpoint=https://example.invalid/" &&
      azurerm_api_management_logger.apim.application_insights[0].identity_client_id == "00000000-0000-0000-0000-000000000003" &&
      azurerm_api_management_logger.apim.timeouts.update == "45m"
    )
    error_message = "The logger must resolve the connection string and resource ID, configure AAD ingestion/Event Hubs, and pass timeouts."
  }
}

run "logger_preserves_instrumentation_key_mode" {
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
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "legacy-logger"
      application_insights = {
        instrumentation_key = "00000000-0000-0000-0000-000000000005"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_logger.apim.application_insights[0].instrumentation_key == "00000000-0000-0000-0000-000000000005"
    error_message = "Existing Application Insights instrumentation-key configurations must remain supported."
  }
}

run "logger_with_eventhub_connection_string" {
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
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "eventhub-key-logger"
      eventhub = {
        name              = "diagnostic-events"
        connection_string = "Endpoint=sb://example.servicebus.windows.net/;SharedAccessKeyName=Send;SharedAccessKey=example-key"
      }
    }
  }

  assert {
    condition = (
      nonsensitive(azurerm_api_management_logger.apim.eventhub[0].connection_string) == "Endpoint=sb://example.servicebus.windows.net/;SharedAccessKeyName=Send;SharedAccessKey=example-key" &&
      azurerm_api_management_logger.apim.eventhub[0].endpoint_uri == null
    )
    error_message = "Event Hub connection-string authentication must remain supported."
  }
}

run "logger_supports_eventhub_without_application_insights" {
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
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "eventhub-only-logger"
      eventhub = {
        name         = "diagnostic-events"
        endpoint_uri = "sb://example.servicebus.windows.net/"
      }
    }
  }

  assert {
    condition = (
      length(azurerm_api_management_logger.apim.application_insights) == 0 &&
      length(azurerm_api_management_logger.apim.eventhub) == 1
    )
    error_message = "An Event Hub logger must not require an Application Insights block."
  }
}

run "logger_rejects_conflicting_application_insights_sources" {
  command         = plan
  expect_failures = [var.settings]

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
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "invalid-logger"
      application_insights = {
        instrumentation_key = "00000000-0000-0000-0000-000000000006"
        connection_string   = "InstrumentationKey=00000000-0000-0000-0000-000000000007"
      }
    }
  }
}

run "logger_rejects_eventhub_without_authentication_source" {
  command         = plan
  expect_failures = [var.settings]

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
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "invalid-eventhub-logger"
      eventhub = {
        name = "diagnostic-events"
      }
    }
  }
}

run "logger_rejects_both_destinations" {
  command         = plan
  expect_failures = [var.settings]

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
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name = "invalid-destination-logger"
      application_insights = {
        instrumentation_key = "00000000-0000-0000-0000-000000000008"
      }
      eventhub = {
        name              = "diagnostic-events"
        connection_string = "Endpoint=sb://example.servicebus.windows.net/;SharedAccessKeyName=Send;SharedAccessKey=example-key"
      }
    }
  }
}

run "typed_global_settings_defaults_applied_when_omitted" {
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
      name        = "defaults-logger"
      resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ns"
      eventhub = {
        name              = "logs"
        connection_string = "Endpoint=sb://example.invalid/;SharedAccessKeyName=key;SharedAccessKey=secret"
      }
    }
  }

  assert {
    condition = (
      azurecaf_name.apim.random_length == 0 &&
      azurecaf_name.apim.passthrough == false &&
      azurecaf_name.apim.use_slug == true &&
      azurecaf_name.apim.prefixes == null
    )
    error_message = "Omitted global_settings attributes must fall back to the declared module defaults."
  }
}

run "typed_global_settings_defaults_applied_for_explicit_null" {
  command = plan

  module {
    source = "../modules/apim/api_management_logger"
  }

  variables {
    global_settings = {
      prefixes      = null
      random_length = null
      passthrough   = null
      use_slug      = null
    }
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name        = "defaults-logger"
      resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ns"
      eventhub = {
        name              = "logs"
        connection_string = "Endpoint=sb://example.invalid/;SharedAccessKeyName=key;SharedAccessKey=secret"
      }
    }
  }

  assert {
    condition = (
      azurecaf_name.apim.random_length == 0 &&
      azurecaf_name.apim.passthrough == false &&
      azurecaf_name.apim.use_slug == true &&
      azurecaf_name.apim.prefixes == null
    )
    error_message = "Explicit null global_settings attributes must be replaced by the declared module defaults."
  }
}

run "typed_global_settings_explicit_values_are_preserved" {
  command = plan

  module {
    source = "../modules/apim/api_management_logger"
  }

  variables {
    global_settings = {
      prefixes      = ["caf"]
      random_length = 3
      passthrough   = true
      use_slug      = false
    }
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    resource_group_name = "example-rg"
    api_management_name = "example-apim"
    settings = {
      name        = "defaults-logger"
      resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.EventHub/namespaces/ns"
      eventhub = {
        name              = "logs"
        connection_string = "Endpoint=sb://example.invalid/;SharedAccessKeyName=key;SharedAccessKey=secret"
      }
    }
  }

  assert {
    condition = (
      azurecaf_name.apim.random_length == 3 &&
      azurecaf_name.apim.passthrough == true &&
      azurecaf_name.apim.use_slug == false &&
      azurecaf_name.apim.prefixes == tolist(["caf"])
    )
    error_message = "Explicit global_settings values must override the declared module defaults."
  }
}
