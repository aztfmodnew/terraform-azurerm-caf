mock_provider "azurerm" {}

run "api_operation_nested_configuration" {
  command = plan

  module {
    source = "../modules/apim/api_management_api_operation"
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
    api_name            = "example-api"
    resource_group_name = "example-rg"
    settings = {
      operation_id = "get-wishlists"
      display_name = "Get WishLists"
      method       = "PATCH"
      url_template = "/wishlists/{id}"
      description  = "Retrieve a wishlist."
      request = {
        description = "Wishlist lookup request."
        headers = {
          authorization = {
            name        = "Authorization"
            required    = true
            type        = "string"
            description = "Bearer token."
            examples = {
              bearer = {
                name  = "Bearer token"
                value = "Bearer example"
              }
            }
          }
        }
        query_parameters = {
          include = {
            name     = "include"
            required = false
            type     = "string"
            values   = ["items", "owner"]
            examples = {
              items = {
                name  = "Include items"
                value = "items"
              }
            }
          }
        }
        representations = {
          form = {
            content_type = "application/x-www-form-urlencoded"
            form_parameters = {
              title = {
                name     = "title"
                required = true
                type     = "string"
                examples = {
                  sample = {
                    name  = "Wishlist title"
                    value = "Summer reading"
                  }
                }
              }
            }
          }
        }
      }
      responses = {
        created = {
          status_code = 201
          description = "Wishlist created."
          headers = {
            location = {
              name     = "Location"
              required = true
              type     = "string"
            }
          }
          representations = {
            json = {
              content_type = "application/json"
              schema_id    = "wishlist-schema"
              type_name    = "Wishlist"
              examples = {
                success = {
                  name  = "Created wishlist"
                  value = "{\"id\":\"123\"}"
                }
              }
            }
          }
        }
      }
      template_parameters = {
        id = {
          name          = "id"
          required      = true
          type          = "string"
          description   = "Wishlist identifier."
          default_value = "123"
          examples = {
            sample = {
              name  = "Wishlist identifier"
              value = "123"
            }
          }
        }
      }
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_api_operation.apim.method == "PATCH"
    error_message = "HTTP operation methods must not be limited to a hard-coded subset."
  }
  assert {
    condition     = one(azurerm_api_management_api_operation.apim.request).header[0].name == "Authorization"
    error_message = "Request headers and examples must be passed through."
  }
  assert {
    condition     = one(azurerm_api_management_api_operation.apim.request).query_parameter[0].name == "include"
    error_message = "Request query parameters must be passed through."
  }
  assert {
    condition     = one(one(azurerm_api_management_api_operation.apim.request).representation).form_parameter[0].name == "title"
    error_message = "Form parameters must be available for URL-encoded representations."
  }
  assert {
    condition     = one(azurerm_api_management_api_operation.apim.response).status_code == 201
    error_message = "API operation responses must be passed through."
  }
  assert {
    condition     = one(azurerm_api_management_api_operation.apim.template_parameter).name == "id"
    error_message = "URL template parameters must be passed through."
  }
}
