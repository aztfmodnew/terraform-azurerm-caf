mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "example-api" }
  }
}

variables {
  global_settings     = { prefixes = [], random_length = 0, passthrough = true, use_slug = false, tags = {} }
  client_config       = { landingzone_key = "local" }
  base_tags           = {}
  remote_objects      = {}
  api_management_name = "example-apim"
  resource_group_name = "example-rg"
}

run "version_requires_version_set" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["https"]
      version      = "v1"
    }
  }
}

run "websocket_requires_service_url" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["wss"]
      api_type     = "websocket"
    }
  }
}

run "wsdl_selector_requires_wsdl_import" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["https"]
      import = {
        content_format = "openapi-link"
        content_value  = "https://example.com/openapi.json"
        wsdl_selector = {
          service_name  = "ExampleService"
          endpoint_name = "ExamplePort"
        }
      }
    }
  }
}

run "unsupported_api_type_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["https"]
      api_type     = "unsupported"
    }
  }
}

run "unsupported_protocol_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["ftp"]
    }
  }
}

run "unsupported_import_format_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["https"]
      import = {
        content_format = "unsupported"
        content_value  = "https://example.com/openapi.json"
      }
    }
  }
}

run "unsupported_bearer_token_method_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["https"]
      openid_authentication = {
        openid_provider_name         = "example-openid"
        bearer_token_sending_methods = ["cookie"]
      }
    }
  }
}

run "creation_requires_display_name" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name      = "example-api"
      revision  = "1"
      path      = "example"
      protocols = ["https"]
    }
  }
}

run "creation_requires_path" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      protocols    = ["https"]
    }
  }
}

run "creation_requires_protocols" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
    }
  }
}

run "empty_path_is_valid_for_root_api" {
  command = plan
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = ""
      protocols    = ["https"]
    }
  }

  assert {
    condition     = azurerm_api_management_api.apim.path == ""
    error_message = "A root API must be allowed to use the provider-supported empty path."
  }
}

run "empty_display_name_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = ""
      path         = "example"
      protocols    = ["https"]
    }
  }
}

run "source_api_allows_omitted_creation_fields" {
  command = plan
  module {
    source = "../modules/apim/api_management_api"
  }
  variables {
    settings = {
      name          = "example-api"
      revision      = "1"
      source_api_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/source"
    }
  }
  assert {
    condition     = azurerm_api_management_api.apim.source_api_id == var.settings.source_api_id
    error_message = "Copying an existing API must retain its source reference without requiring creation fields."
  }
}
