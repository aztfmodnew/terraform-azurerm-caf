mock_provider "azurerm" {}

run "product_and_inline_policy_support_provider_options" {
  command = plan

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id            = "contract-product"
      display_name          = "Contract Product"
      published             = true
      subscription_required = true
      approval_required     = false
      subscriptions_limit   = 20
      description           = "Product with complete provider options"
      terms                 = "Terms for the contract product"
      policy = {
        xml_content = "<policies><inbound /></policies>"
        timeouts = {
          create = "40m"
          read   = "6m"
          update = "40m"
          delete = "40m"
        }
      }
      timeouts = {
        create = "45m"
        read   = "7m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_product.apim.product_id == "contract-product" &&
      azurerm_api_management_product.apim.display_name == "Contract Product" &&
      azurerm_api_management_product.apim.published &&
      azurerm_api_management_product.apim.subscription_required &&
      azurerm_api_management_product.apim.approval_required == false &&
      azurerm_api_management_product.apim.subscriptions_limit == 20 &&
      azurerm_api_management_product.apim.description == "Product with complete provider options" &&
      azurerm_api_management_product.apim.terms == "Terms for the contract product" &&
      azurerm_api_management_product.apim.timeouts.update == "45m" &&
      azurerm_api_management_product_policy.apim[0].xml_content == "<policies><inbound /></policies>" &&
      azurerm_api_management_product_policy.apim[0].timeouts.update == "40m"
    )
    error_message = "The product and optional inline policy must pass provider arguments and independent timeouts."
  }
}

run "product_defaults_subscription_required_and_omits_policy" {
  command = plan

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id   = "default-product"
      display_name = "Default Product"
      published    = false
    }
  }

  assert {
    condition = (
      azurerm_api_management_product.apim.subscription_required &&
      azurerm_api_management_product.apim.approval_required == null &&
      azurerm_api_management_product.apim.subscriptions_limit == null &&
      length(azurerm_api_management_product_policy.apim) == 0 &&
      output.policy_id == null
    )
    error_message = "Omitted settings must retain the provider's subscription default and omit the optional policy."
  }
}

run "product_policy_preserves_xml_file_precedence" {
  command = plan

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id   = "file-policy-product"
      display_name = "File Policy Product"
      published    = true
      policy = {
        xml_file    = "apim/117-api_management_product/policies/example-policy.xml"
        xml_content = "<policies><inbound><base /></inbound></policies>"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_product_policy.apim[0].xml_content ==
      file("${path.cwd}/apim/117-api_management_product/policies/example-policy.xml")
    )
    error_message = "A configured XML file must retain precedence over the legacy inline-content fallback."
  }
}

run "product_policy_supports_xml_link" {
  command = plan

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id   = "linked-policy-product"
      display_name = "Linked Policy Product"
      published    = true
      policy = {
        xml_link = "https://example.com/product-policy.xml"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_product_policy.apim[0].xml_link == "https://example.com/product-policy.xml"
    error_message = "A public XML policy link must be passed to the product policy resource."
  }
}

run "product_rejects_approval_without_subscription" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id            = "invalid-approval-product"
      display_name          = "Invalid Approval Product"
      published             = true
      subscription_required = false
      approval_required     = true
    }
  }
}

run "product_rejects_limit_without_subscription" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id            = "invalid-limit-product"
      display_name          = "Invalid Limit Product"
      published             = true
      subscription_required = false
      subscriptions_limit   = 5
    }
  }
}

run "product_policy_rejects_conflicting_sources" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id   = "invalid-source-product"
      display_name = "Invalid Source Product"
      published    = true
      policy = {
        xml_content = "<policies />"
        xml_link    = "https://example.com/product-policy.xml"
      }
    }
  }
}

run "product_policy_rejects_missing_source" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_product"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      product_id   = "invalid-missing-source-product"
      display_name = "Invalid Missing Source Product"
      published    = true
      policy       = {}
    }
  }
}
