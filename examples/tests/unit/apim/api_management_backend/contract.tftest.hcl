mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-backend" }
  }
}

run "backend_advanced_options_and_circuit_breaker" {
  command = plan

  module {
    source = "../modules/apim/api_management_backend"
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
      name        = "example-backend"
      protocol    = "http"
      url         = "https://backend.example.com/api"
      description = "Backend for example service"
      resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Web/sites/example-app"
      title       = "Example backend"
      credentials = {
        authorization = {
          parameter = "token"
          scheme    = "Bearer"
        }
        certificate = ["thumbprint"]
        header      = { "X-Environment" = "test" }
        query       = { version = "v1" }
      }
      proxy = {
        url      = "https://proxy.example.com"
        username = "proxy-user"
        password = "proxy-password"
      }
      service_fabric_cluster = {
        client_certificate_thumbprint    = "client-thumbprint"
        management_endpoints             = ["https://cluster.example.com"]
        max_partition_resolution_retries = 3
        server_x509_name = [{
          issuer_certificate_thumbprint = "issuer-thumbprint"
          name                          = "cluster.example.com"
        }]
      }
      tls = {
        validate_certificate_chain = true
        validate_certificate_name  = true
      }
      circuit_breaker_rule = {
        name                       = "backend-breaker"
        trip_duration              = "PT1M"
        accept_retry_after_enabled = true
        failure_condition = {
          interval_duration = "PT5M"
          count             = 5
          error_reasons     = ["BackendConnectionFailure"]
          status_code_range = [{
            min = 500
            max = 599
          }]
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
    condition     = azurerm_api_management_backend.apim.name == "example-backend"
    error_message = "The backend must use the CAF-generated name."
  }
  assert {
    condition     = one(azurerm_api_management_backend.apim.credentials).authorization[0].scheme == "Bearer"
    error_message = "Backend authorization must be nested under credentials."
  }
  assert {
    condition     = one(azurerm_api_management_backend.apim.proxy).url == "https://proxy.example.com"
    error_message = "Backend proxy settings must be passed through."
  }
  assert {
    condition     = contains([for x509_name in one(azurerm_api_management_backend.apim.service_fabric_cluster).server_x509_name : x509_name.name], "cluster.example.com")
    error_message = "Server X.509 names must be nested within the Service Fabric cluster block."
  }
  assert {
    condition     = one(one(azurerm_api_management_backend.apim.circuit_breaker_rule).failure_condition).count == 5
    error_message = "Circuit breaker failure condition settings must be passed through."
  }
  assert {
    condition     = one(azurerm_api_management_backend.apim.tls).validate_certificate_name
    error_message = "Backend TLS validation settings must be passed through."
  }
  assert {
    condition     = azurerm_api_management_backend.apim.timeouts.update == "40m"
    error_message = "Backend operation timeouts must be passed through."
  }
}

run "backend_legacy_service_fabric_server_name" {
  command = plan

  module {
    source = "../modules/apim/api_management_backend"
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
      name     = "example-backend"
      protocol = "soap"
      url      = "https://backend.example.com/service"
      server_x509_name = {
        issuer_certificate_thumbprint = "legacy-issuer-thumbprint"
        name                          = "legacy.example.com"
      }
      service_fabric_cluster = {
        client_certificate_thumbprint    = "client-thumbprint"
        management_endpoints             = ["https://cluster.example.com"]
        max_partition_resolution_retries = 3
      }
    }
  }

  assert {
    condition     = contains([for x509_name in one(azurerm_api_management_backend.apim.service_fabric_cluster).server_x509_name : x509_name.name], "legacy.example.com")
    error_message = "The legacy top-level server_x509_name setting must remain supported."
  }
}

run "backend_breaker_requires_exactly_one_threshold" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_backend"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name     = "example-backend"
      protocol = "http"
      url      = "https://backend.example.com/api"
      circuit_breaker_rule = {
        name          = "backend-breaker"
        trip_duration = "PT1M"
        failure_condition = {
          interval_duration = "PT5M"
          count             = 5
          percentage        = 50
          error_reasons     = ["BackendConnectionFailure"]
        }
      }
    }
  }
}
