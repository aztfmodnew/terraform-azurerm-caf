mock_provider "azurerm" {}

run "api_policy_with_xml_content_and_timeouts" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_policy"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_name            = "example-api"
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      api = { key = "example-api" }
      api_management = {
        key = "example-apim"
      }
      resource_group = { key = "example-rg" }
      xml_content    = "<policies><inbound /></policies>"
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_api_policy.apim.xml_content == "<policies><inbound /></policies>"
    error_message = "The API policy XML content must be passed to the provider."
  }
  assert {
    condition     = azurerm_api_management_api_policy.apim.timeouts.update == "40m"
    error_message = "The API policy timeouts must be passed to the provider."
  }
}

run "api_policy_with_xml_link" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_policy"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_name            = "example-api"
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      api            = { key = "example-api" }
      xml_link       = "https://example.com/policy.xml"
      timeouts       = {}
      api_management = { key = "example-apim" }
      resource_group = { key = "example-rg" }
    }
  }

  assert {
    condition     = azurerm_api_management_api_policy.apim.xml_link == "https://example.com/policy.xml"
    error_message = "The API policy XML link must be passed to the provider."
  }
}
