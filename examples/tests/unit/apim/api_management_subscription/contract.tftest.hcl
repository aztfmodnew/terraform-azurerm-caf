mock_provider "azurerm" {}

run "subscription_supports_product_user_keys_and_timeouts" {
  command = plan

  module {
    source = "../modules/apim/api_management_subscription"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    product_id          = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/products/example-product"
    settings = {
      display_name    = "Contract Subscription"
      user_id         = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/users/example-user"
      primary_key     = "primary-test-key"
      secondary_key   = "secondary-test-key"
      subscription_id = "contract-subscription"
      state           = "suspended"
      allow_tracing   = false
      product         = { key = "example-product", lz_key = "local" }
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_subscription.apim.display_name == "Contract Subscription" &&
      azurerm_api_management_subscription.apim.product_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/products/example-product" &&
      azurerm_api_management_subscription.apim.user_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/users/example-user" &&
      nonsensitive(azurerm_api_management_subscription.apim.primary_key) == "primary-test-key" &&
      nonsensitive(azurerm_api_management_subscription.apim.secondary_key) == "secondary-test-key" &&
      azurerm_api_management_subscription.apim.subscription_id == "contract-subscription" &&
      azurerm_api_management_subscription.apim.state == "suspended" &&
      azurerm_api_management_subscription.apim.allow_tracing == false &&
      azurerm_api_management_subscription.apim.timeouts.update == "40m"
    )
    error_message = "Subscription settings, sensitive key inputs, resolved product ID, and provider timeouts must be passed through."
  }
}

run "subscription_supports_api_scope_without_product" {
  command = plan

  module {
    source = "../modules/apim/api_management_subscription"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      display_name = "API Subscription"
      api_id       = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/example-api"
      user_id      = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/users/example-user"
    }
  }

  assert {
    condition = (
      azurerm_api_management_subscription.apim.api_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/example-api" &&
      azurerm_api_management_subscription.apim.product_id == null &&
      azurerm_api_management_subscription.apim.user_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/users/example-user"
    )
    error_message = "An API-scoped subscription must support api_id without a product."
  }
}

run "subscription_defaults_to_all_apis_and_provider_defaults" {
  command = plan

  module {
    source = "../modules/apim/api_management_subscription"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      display_name = "All APIs Subscription"
    }
  }

  assert {
    condition = (
      azurerm_api_management_subscription.apim.product_id == null &&
      azurerm_api_management_subscription.apim.api_id == null &&
      azurerm_api_management_subscription.apim.state == "submitted" &&
      azurerm_api_management_subscription.apim.allow_tracing
    )
    error_message = "Subscriptions without product or API references must preserve the all-APIs scope and provider defaults."
  }
}

run "subscription_rejects_product_and_api_scope_together" {
  command         = plan
  expect_failures = [azurerm_api_management_subscription.apim]

  module {
    source = "../modules/apim/api_management_subscription"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    product_id          = "example-product-id"
    settings = {
      display_name = "Invalid Scope Subscription"
      api_id       = "example-api-id"
    }
  }
}

run "subscription_rejects_unsupported_state" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_subscription"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      display_name = "Invalid State Subscription"
      state        = "pending"
    }
  }
}
