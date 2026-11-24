mock_provider "azapi" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "ai-pool" }
  }
}

run "pool_composes_weighted_child_ids" {
  command = plan
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = { passthrough = true, random_length = 0, use_slug = false }
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-pool"
      api_version       = "2025-09-01-preview"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services = [
        {
          id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/east"
          weight   = 70
          priority = 1
        },
        {
          id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/west"
          weight   = 30
          priority = 2
        }
      ]
      session_affinity             = { cookie_name = "ai-session" }
      failure_response_status_code = 503
      timeouts                     = { update = "40m" }
    }
  }
  assert {
    condition     = azapi_resource.resource.body.properties.type == "Pool" && length(azapi_resource.resource.body.properties.pool.services) == 2
    error_message = "The backend pool must compose both APIM service child IDs."
  }
  assert {
    condition     = azapi_resource.resource.body.properties.pool.services[0].weight == 70 && azapi_resource.resource.body.properties.pool.services[1].priority == 2
    error_message = "Member weight and priority must reach the ARM body."
  }
  assert {
    condition     = azapi_resource.resource.body.properties.pool.sessionAffinity.sessionId.name == "ai-session" && azapi_resource.resource.body.properties.pool.failureResponse.statusCode == 503
    error_message = "Preview pool session affinity and failure response must be represented."
  }
}

run "stable_api_rejects_session_affinity" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-pool"
      api_version       = "2024-05-01"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services          = [{ id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/east" }]
      session_affinity  = { cookie_name = "session" }
    }
  }
}

run "remote_ai_backend_and_standard_backend_keys_resolve" {
  command = plan
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects = {
      ai_backends = {
        remote = {
          east = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/east-remote"
          }
        }
      }
      backends = {
        partner = {
          west = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/west-remote"
          }
        }
      }
    }
    settings = {
      name              = "ai-pool"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services = [
        { key = "east", lz_key = "remote", source = "ai_backends", weight = 0 },
        { key = "west", lz_key = "partner", source = "backends", weight = 100 }
      ]
    }
  }
  assert {
    condition     = endswith(output.service_ids[0], "/backends/east-remote") && endswith(output.service_ids[1], "/backends/west-remote")
    error_message = "Pool members must resolve keys from AI and standard backend objects in remote landing zones."
  }
  assert {
    condition     = azapi_resource.resource.body.properties.pool.services[0].weight == 0 && azapi_resource.resource.body.properties.pool.services[1].weight == 100
    error_message = "Pool weights at both inclusive boundaries must be accepted."
  }
}

run "missing_remote_backend_key_is_rejected" {
  command         = plan
  expect_failures = [azapi_resource.resource]
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-pool"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services          = [{ key = "missing", source = "ai_backends" }]
    }
  }
}

run "ambiguous_member_reference_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-pool"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services = [{
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim/backends/east"
        name = "east"
      }]
    }
  }
}

run "unsupported_member_source_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-pool"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services          = [{ key = "east", source = "unknown" }]
    }
  }
}

run "weight_below_zero_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-pool"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services          = [{ name = "east", weight = -1 }]
    }
  }
}

run "weight_above_one_hundred_is_rejected" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/apim/api_management_backend_pool"
  }
  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    settings = {
      name              = "ai-pool"
      api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ApiManagement/service/apim"
      services          = [{ name = "east", weight = 101 }]
    }
  }
}
