mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-api-center/providers/Microsoft.ApiCenter/services/api-center-root-test"
    }
  }
}
mock_provider "azurerm" {}
mock_provider "azurerm" {
  alias = "vhub"
}
mock_provider "azuread" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "api-center-root-test" }
  }
}
mock_provider "time" {}

run "root_dispatches_api_center_and_rbac_scope" {
  command = plan

  variables {
    global_settings = {
      passthrough    = true
      random_length  = 0
      use_slug       = false
      default_region = "region1"
      regions        = { region1 = "westeurope" }
    }
    resource_groups = {
      catalog = {
        name = "rg-api-center"
      }
    }
    api_center = {
      catalog = {
        name = "api-center"
        service = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-api-center/providers/Microsoft.ApiCenter/services/api-center-root-test"
        }
        resource_group = {
          key = "catalog"
        }
        workspaces = {
          default = {
            name  = "default"
            title = "Default"
          }
        }
      }
    }
    role_mapping = {
      built_in_role_mapping = {
        api_centers = {
          catalog = {
            "Azure API Center Data Reader" = {
              object_ids = {
                keys = ["00000000-0000-0000-0000-000000000042"]
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition     = length(module.example.api_center) == 1
    error_message = "The examples root must expose the integration.api_center composition."
  }

  assert {
    condition = (
      one(values(module.example.role_assignment_targets)).principal_id == "00000000-0000-0000-0000-000000000042" &&
      one(values(module.example.role_assignment_targets)).scope == module.example.api_center["catalog"].id
    )
    error_message = "Generic RBAC mappings must resolve an API Center service as the role scope."
  }
}
