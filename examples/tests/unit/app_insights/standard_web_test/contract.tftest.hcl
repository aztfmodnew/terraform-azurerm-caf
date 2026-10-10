mock_provider "azapi" {}
mock_provider "azurecaf" {}

variables {
  name                    = "contract-standard-test"
  location                = "westeurope"
  resource_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/contract-rg"
  application_insights_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/contract-rg/providers/Microsoft.Insights/components/contract"
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
  }
}

run "preserves_defaults_and_hidden_link" {
  command = plan
  module {
    source = "../modules/app_insights/standard_web_test"
  }
  variables {
    settings = {
      request_url   = "https://example.invalid"
      geo_locations = ["emea-nl-ams-azr"]
    }
  }
  assert {
    condition = (
      azapi_resource.appiwt.body.kind == "standard" &&
      azapi_resource.appiwt.body.properties.Frequency == 300 &&
      azapi_resource.appiwt.body.properties.Request.HttpVerb == "GET" &&
      !azapi_resource.appiwt.body.properties.Request.ParseDependentRequests &&
      !azapi_resource.appiwt.body.properties.ValidationRules.SSLCheck &&
      azapi_resource.appiwt.tags["hidden-link:${var.application_insights_id}"] == "Resource"
    )
    error_message = "Default body configuration and parent linking must be preserved."
  }
}

run "passes_request_validation_xml_and_timeouts" {
  command = plan
  module {
    source = "../modules/app_insights/standard_web_test"
  }
  variables {
    settings = {
      request_url               = "https://example.invalid/status"
      geo_locations             = ["emea-nl-ams-azr"]
      http_verb                 = "POST"
      request_body              = "e30="
      request_headers           = [{ key = "Content-Type", value = "application/json" }]
      follow_redirects          = false
      parse_dependent_requests  = true
      frequency                 = 600
      timeout                   = 60
      enabled                   = false
      retry_enabled             = false
      description               = "Contract"
      expected_http_status_code = 201
      ignore_http_status_code   = false
      content_validation = {
        ContentMatch    = "healthy"
        IgnoreCase      = true
        PassIfTextFound = true
      }
      ssl_check_enabled                 = true
      ssl_cert_remaining_lifetime_check = 30
      configuration                     = { web_test = "<WebTest />" }
      timeouts                          = { create = "40m", read = "6m", update = "40m", delete = "40m" }
    }
  }
  assert {
    condition = (
      azapi_resource.appiwt.body.properties.Request.RequestBody == "e30=" &&
      azapi_resource.appiwt.body.properties.Request.Headers[0].key == "Content-Type" &&
      azapi_resource.appiwt.body.properties.Request.HttpVerb == "POST" &&
      !azapi_resource.appiwt.body.properties.Request.FollowRedirects &&
      azapi_resource.appiwt.body.properties.Configuration.WebTest == "<WebTest />" &&
      azapi_resource.appiwt.body.properties.ValidationRules.ContentValidation.ContentMatch == "healthy" &&
      azapi_resource.appiwt.body.properties.ValidationRules.SSLCertRemainingLifetimeCheck == 30 &&
      azapi_resource.appiwt.body.properties.ValidationRules.ExpectedHttpStatusCode == 201 &&
      azapi_resource.appiwt.timeouts.create == "40m" &&
      azapi_resource.appiwt.timeouts.read == "6m" &&
      azapi_resource.appiwt.timeouts.update == "40m" &&
      azapi_resource.appiwt.timeouts.delete == "40m"
    )
    error_message = "Request, validation, XML and timeout options must reach the resource."
  }
}

run "rejects_invalid_frequency" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/app_insights/standard_web_test"
  }
  variables {
    settings = {
      request_url   = "https://example.invalid"
      geo_locations = ["emea-nl-ams-azr"]
      frequency     = 42
    }
  }
}

run "rejects_lifetime_without_ssl_check" {
  command         = plan
  expect_failures = [var.settings]
  module {
    source = "../modules/app_insights/standard_web_test"
  }
  variables {
    settings = {
      request_url                       = "https://example.invalid"
      geo_locations                     = ["emea-nl-ams-azr"]
      ssl_cert_remaining_lifetime_check = 30
    }
  }
}
