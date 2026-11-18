mock_provider "azurerm" {}

variables {
  global_settings = {}
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    api_management = {
      local  = { gateway = { name = "local-apim" } }
      remote = { gateway = { name = "remote-apim" } }
    }
    resource_groups = {
      local  = { gateway = { name = "local-rg" } }
      remote = { gateway = { name = "remote-rg" } }
    }
    api_management_product = {
      local  = { gateway = { id = "/products/local", product_id = "local-product" } }
      remote = { gateway = { id = "/products/remote", product_id = "remote-product" } }
    }
  }
}

run "local_product_uses_logical_identifier" {
  command = plan
  module {
    source = "../modules/apim/api_management_product_policy"
  }
  variables {
    settings = {
      api_management = { key = "gateway" }
      resource_group = { key = "gateway" }
      product        = { key = "gateway" }
      xml_content    = "<policies><inbound><base /></inbound></policies>"
      timeouts       = { create = "45m" }
    }
  }
  assert {
    condition = (
      azurerm_api_management_product_policy.policy.product_id == "local-product" &&
      azurerm_api_management_product_policy.policy.api_management_name == "local-apim" &&
      azurerm_api_management_product_policy.policy.resource_group_name == "local-rg" &&
      azurerm_api_management_product_policy.policy.timeouts.create == "45m"
    )
    error_message = "The product policy must resolve local references and the logical product identifier."
  }
}

run "remote_product_and_link" {
  command = plan
  module {
    source = "../modules/apim/api_management_product_policy"
  }
  variables {
    settings = {
      api_management = { key = "gateway", lz_key = "remote" }
      resource_group = { key = "gateway", lz_key = "remote" }
      product        = { key = "gateway", lz_key = "remote" }
      xml_link       = "https://example.com/policy.xml"
    }
  }
  assert {
    condition = (
      azurerm_api_management_product_policy.policy.product_id == "remote-product" &&
      azurerm_api_management_product_policy.policy.api_management_name == "remote-apim" &&
      azurerm_api_management_product_policy.policy.resource_group_name == "remote-rg"
    )
    error_message = "Cross-landing-zone product references must resolve independently."
  }
}

run "explicit_values_override_references" {
  command = plan
  module {
    source = "../modules/apim/api_management_product_policy"
  }
  variables {
    settings = {
      api_management      = { name = "explicit-apim", key = "missing" }
      resource_group_name = "explicit-rg"
      product_id          = "explicit-product"
      product             = { key = "missing" }
      xml_content         = "<policies />"
    }
  }
  assert {
    condition = (
      azurerm_api_management_product_policy.policy.product_id == "explicit-product" &&
      azurerm_api_management_product_policy.policy.api_management_name == "explicit-apim" &&
      azurerm_api_management_product_policy.policy.resource_group_name == "explicit-rg"
    )
    error_message = "Explicit identifiers must take precedence over key references."
  }
}

run "reject_two_policy_sources" {
  command = plan
  module {
    source = "../modules/apim/api_management_product_policy"
  }
  variables {
    settings = {
      api_management      = { name = "explicit-apim" }
      resource_group_name = "explicit-rg"
      product_id          = "explicit-product"
      xml_content         = "<policies />"
      xml_link            = "https://example.com/policy.xml"
    }
  }
  expect_failures = [var.settings]
}

run "reject_missing_policy_source" {
  command = plan
  module {
    source = "../modules/apim/api_management_product_policy"
  }
  variables {
    settings = {
      api_management      = { name = "explicit-apim" }
      resource_group_name = "explicit-rg"
      product_id          = "explicit-product"
    }
  }
  expect_failures = [var.settings]
}
