mock_provider "azurerm" {}

run "operation_policy_with_direct_operation_id" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_operation_policy"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    api_name            = "example-api"
    resource_group_name = "example-rg"
    settings = {
      api_operation = { id = "sample-operation" }
      xml_content   = "<policies><inbound /></policies>"
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.operation_id == "sample-operation"
    error_message = "The policy must accept a direct API operation identifier."
  }
  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.xml_content == "<policies><inbound /></policies>"
    error_message = "The policy XML content must be passed to the provider."
  }
  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.timeouts.update == "40m"
    error_message = "The API operation policy timeouts must be passed to the provider."
  }
}

run "operation_policy_with_local_operation_key_and_xml_link" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_operation_policy"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      api_management_api_operation = {
        local = {
          sample = {
            id           = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/example-api/operations/operation-arm-id"
            operation_id = "resolved-operation"
          }
        }
      }
    }
    api_management_name = "example-apim"
    api_name            = "example-api"
    resource_group_name = "example-rg"
    settings = {
      api_operation = { key = "sample" }
      xml_link      = "https://example.com/policy.xml"
    }
  }

  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.operation_id == "resolved-operation"
    error_message = "The policy must resolve a local operation key through remote_objects."
  }
  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.xml_link == "https://example.com/policy.xml"
    error_message = "The policy XML link must be passed to the provider."
  }
}

run "operation_policy_with_remote_operation_key" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_operation_policy"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      api_management_api_operation = {
        remote = {
          sample = {
            id           = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/example-api/operations/remote-arm-id"
            operation_id = "remote-operation"
          }
        }
      }
    }
    api_management_name = "example-apim"
    api_name            = "example-api"
    resource_group_name = "example-rg"
    settings = {
      api_operation = {
        key    = "sample"
        lz_key = "remote"
      }
      xml_content = "<policies><outbound /></policies>"
    }
  }

  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.operation_id == "remote-operation"
    error_message = "The policy must resolve an operation key from the configured landing zone."
  }
}

run "operation_policy_explicit_remote_landing_zone_wins_key_collision" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_operation_policy"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      api_management_api_operation = {
        local = {
          sample = { operation_id = "local-operation" }
        }
        remote = {
          sample = { operation_id = "remote-operation" }
        }
      }
    }
    api_management_name = "example-apim"
    api_name            = "example-api"
    resource_group_name = "example-rg"
    settings = {
      api_operation = {
        key    = "sample"
        lz_key = "remote"
      }
      xml_content = "<policies><outbound /></policies>"
    }
  }

  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.operation_id == "remote-operation"
    error_message = "An explicit landing-zone key must select that landing zone even when the local landing zone has the same operation key."
  }
}

run "operation_policy_normalizes_legacy_arm_operation_output" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_operation_policy"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      api_management_api_operation = {
        local = {
          sample = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/example-api/operations/legacy-operation"
          }
        }
      }
    }
    api_management_name = "example-apim"
    api_name            = "example-api"
    resource_group_name = "example-rg"
    settings = {
      api_operation = { key = "sample" }
      xml_content   = "<policies><inbound /></policies>"
    }
  }

  assert {
    condition     = azurerm_api_management_api_operation_policy.apim.operation_id == "legacy-operation"
    error_message = "Legacy API operation ARM IDs must be reduced to the logical operation identifier before being passed to the provider."
  }
}
