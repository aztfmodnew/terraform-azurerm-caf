mock_provider "azurerm" {
  mock_resource "azurerm_fabric_capacity" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Fabric/capacities/fabric-test"
    }
  }
}

variables {
  global_settings = {
    default_region = "region1"
    regions        = { region1 = "australiaeast" }
    tags           = { environment = "test" }
  }
  client_config = { landingzone_key = "local" }
  resource_group = {
    name     = "test-rg"
    location = "australiaeast"
    tags     = { cost_center = "analytics" }
  }
  location  = null
  base_tags = true
}

run "all_provider_options_and_outputs_are_supported" {
  command = plan

  module {
    source = "../modules/analytics/fabric_capacity"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    resource_group  = var.resource_group
    location        = var.location
    base_tags       = var.base_tags
    settings = {
      name = "fabric-test"
      sku = {
        name = "F16"
        tier = "Fabric"
      }
      administration_members = [
        "dataops_lead@contoso.com",
        "00000000-0000-0000-0000-000000000001"
      ]
      tags = { owner = "analytics-team" }
      timeouts = {
        create = "35m"
        read   = "7m"
        update = "35m"
        delete = "35m"
      }
    }
  }

  assert {
    condition = (
      azurerm_fabric_capacity.fabric_capacity.resource_group_name == "test-rg" &&
      azurerm_fabric_capacity.fabric_capacity.location == "australiaeast" &&
      azurerm_fabric_capacity.fabric_capacity.sku[0].name == "F16" &&
      azurerm_fabric_capacity.fabric_capacity.sku[0].tier == "Fabric" &&
      length(azurerm_fabric_capacity.fabric_capacity.administration_members) == 2 &&
      contains(azurerm_fabric_capacity.fabric_capacity.administration_members, "00000000-0000-0000-0000-000000000001") &&
      azurerm_fabric_capacity.fabric_capacity.tags.environment == "test" &&
      azurerm_fabric_capacity.fabric_capacity.tags.cost_center == "analytics" &&
      azurerm_fabric_capacity.fabric_capacity.tags.owner == "analytics-team"
    )
    error_message = "Fabric Capacity must accept the provider arguments and merge inherited and resource tags."
  }

  assert {
    condition = (
      output.id == azurerm_fabric_capacity.fabric_capacity.id &&
      output.sku[0].name == "F16" &&
      output.administration_members == azurerm_fabric_capacity.fabric_capacity.administration_members
    )
    error_message = "The module must expose the capacity ID, SKU, and administrator members."
  }
}

run "fabric_tier_is_defaulted_when_omitted" {
  command = plan

  module {
    source = "../modules/analytics/fabric_capacity"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    resource_group  = var.resource_group
    location        = var.location
    base_tags       = false
    settings = {
      name = "fabric-default-tier"
      sku = {
        name = "F4"
      }
    }
  }

  assert {
    condition = (
      azurerm_fabric_capacity.fabric_capacity.sku[0].name == "F4" &&
      azurerm_fabric_capacity.fabric_capacity.sku[0].tier == "Fabric" &&
      azurerm_fabric_capacity.fabric_capacity.tags.module == "fabric_capacity"
    )
    error_message = "Omitting optional tags and the SKU tier must preserve CAF tags and the Fabric tier default."
  }
}

run "unsupported_sku_name_is_rejected" {
  command = plan

  module {
    source = "../modules/analytics/fabric_capacity"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    resource_group  = var.resource_group
    location        = var.location
    base_tags       = false
    settings = {
      name = "fabric-invalid-sku"
      sku = {
        name = "F1"
      }
    }
  }

  expect_failures = [azurerm_fabric_capacity.fabric_capacity]
}

run "unsupported_sku_tier_is_rejected" {
  command = plan

  module {
    source = "../modules/analytics/fabric_capacity"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    resource_group  = var.resource_group
    location        = var.location
    base_tags       = false
    settings = {
      name = "fabric-invalid-tier"
      sku = {
        name = "F2"
        tier = "Premium"
      }
    }
  }

  expect_failures = [azurerm_fabric_capacity.fabric_capacity]
}
