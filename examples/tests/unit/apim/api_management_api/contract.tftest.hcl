mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "example-api" }
  }
}

run "api_management_api_provider_options" {
  command = plan

  module {
    source = "../modules/apim/api_management_api"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name           = "example-api"
      revision       = "1"
      resource_group = { key = "example-rg" }
      api_management = { key = "example-apim" }
      display_name   = "Example API"
      path           = "example"
      protocols      = ["https"]
      contact        = { name = "API team", email = "api@example.com", url = "https://example.com/contact" }
      description    = "Example API description"
      import = {
        content_format = "wsdl"
        content_value  = "https://example.com/service.wsdl"
        wsdl_selector = {
          service_name  = "ExampleService"
          endpoint_name = "ExamplePort"
        }
      }
      license = {
        name = "Example License"
        url  = "https://example.com/license"
      }
      oauth2_authorization = {
        authorization_server_name = "example-oauth"
        scope                     = "read"
      }
      service_url = "https://example.com/api"
      subscription_key_parameter_names = {
        header = "X-API-Key"
        query  = "api_key"
      }
      terms_of_service_url = "https://example.com/terms"
      version              = "v1"
      version_set_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apiVersionSets/example"
      revision_description = "Initial revision"
      version_description  = "First version"
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_api.apim.api_type == "http"
    error_message = "The default API type must remain http."
  }
  assert {
    condition     = azurerm_api_management_api.apim.subscription_required
    error_message = "The default API subscription requirement must remain enabled."
  }
  assert {
    condition     = one(azurerm_api_management_api.apim.contact).email == "api@example.com"
    error_message = "The API contact block must be passed to the resource."
  }
  assert {
    condition     = one(azurerm_api_management_api.apim.license).name == "Example License"
    error_message = "The API license block must be passed to the resource."
  }
  assert {
    condition     = one(azurerm_api_management_api.apim.import).wsdl_selector[0].service_name == "ExampleService"
    error_message = "The WSDL selector must be passed through the import block."
  }
  assert {
    condition     = one(azurerm_api_management_api.apim.oauth2_authorization).authorization_server_name == "example-oauth"
    error_message = "OAuth2 authorization settings must be passed to the resource."
  }
  assert {
    condition     = one(azurerm_api_management_api.apim.subscription_key_parameter_names).header == "X-API-Key"
    error_message = "Subscription key parameter names must be passed to the resource."
  }
  assert {
    condition     = azurerm_api_management_api.apim.terms_of_service_url == "https://example.com/terms"
    error_message = "The terms of service URL must be passed to the resource."
  }
}

run "api_management_api_openid_authentication" {
  command = plan

  module {
    source = "../modules/apim/api_management_api"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["https"]
      openid_authentication = {
        openid_provider_name         = "example-openid"
        bearer_token_sending_methods = ["query"]
      }
    }
  }

  assert {
    condition     = contains(tolist(one(azurerm_api_management_api.apim.openid_authentication).bearer_token_sending_methods), "query")
    error_message = "OpenID bearer token sending methods must be passed to the resource."
  }
}

run "api_management_api_authentication_exclusive" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_api"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name         = "example-api"
      revision     = "1"
      display_name = "Example API"
      path         = "example"
      protocols    = ["https"]
      oauth2_authorization = {
        authorization_server_name = "example-oauth"
      }
      openid_authentication = {
        openid_provider_name = "example-openid"
      }
    }
  }
}
