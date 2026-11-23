mock_provider "azurerm" {
  source = "./tests/mock_data"

  mock_data "azurerm_api_management" {
    override_during = plan
    defaults        = { id = "resolved-service", name = "existing-service" }
  }
  mock_data "azurerm_api_management_api" {
    override_during = plan
    defaults        = { id = "resolved-api", name = "existing-api" }
  }
  mock_data "azurerm_api_management_api_version_set" {
    override_during = plan
    defaults        = { id = "resolved-version-set", name = "existing-version-set" }
  }
  mock_data "azurerm_api_management_gateway" {
    override_during = plan
    defaults        = { id = "resolved-gateway", name = "existing-gateway" }
  }
  mock_data "azurerm_api_management_gateway_host_name_configuration" {
    override_during = plan
    defaults        = { id = "resolved-hostname", name = "existing-hostname" }
  }
  mock_data "azurerm_api_management_group" {
    override_during = plan
    defaults        = { id = "resolved-group", name = "existing-group" }
  }
  mock_data "azurerm_api_management_product" {
    override_during = plan
    defaults        = { id = "resolved-product", product_id = "existing-product" }
  }
  mock_data "azurerm_api_management_subscription" {
    override_during = plan
    defaults        = { id = "resolved-subscription", subscription_id = "existing-subscription" }
  }
  mock_data "azurerm_api_management_user" {
    override_during = plan
    defaults        = { id = "resolved-user", user_id = "existing-user" }
  }
  mock_data "azurerm_api_management_workspace" {
    override_during = plan
    defaults        = { id = "resolved-workspace", name = "existing-workspace" }
  }
}

mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"
}
mock_provider "azuread" {
  source = "./tests/mock_data"
}
mock_provider "azapi" {}
mock_provider "azurecaf" {}
mock_provider "external" {
  source = "./tests/mock_data"
}
mock_provider "local" {}
mock_provider "null" {}
mock_provider "random" {}
mock_provider "time" {}
mock_provider "tls" {}

variables {
  client_config = {
    landingzone_key         = "local"
    client_id               = "00000000-0000-0000-0000-000000000001"
    object_id               = "00000000-0000-0000-0000-000000000002"
    subscription_id         = "00000000-0000-0000-0000-000000000003"
    tenant_id               = "00000000-0000-0000-0000-000000000004"
    logged_user_objectId    = "00000000-0000-0000-0000-000000000002"
    logged_aad_app_objectId = "00000000-0000-0000-0000-000000000002"
  }
}

run "all_provider_lookups_reach_combined_objects" {
  command = plan
  module {
    source = "../"
  }
  variables {
    data_sources = {
      api_management = {
        existing = { name = "existing-service", resource_group_name = "existing-rg", timeouts = { read = "10m" } }
      }
      api_management_api = {
        existing = { name = "existing-api", api_management_name = "existing-service", resource_group_name = "existing-rg", revision = "1" }
      }
      api_management_api_version_set = {
        existing = { name = "existing-version-set", api_management_name = "existing-service", resource_group_name = "existing-rg" }
      }
      api_management_gateway = {
        existing = { name = "existing-gateway", api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/existing-rg/providers/Microsoft.ApiManagement/service/existing-service" }
      }
      api_management_gateway_host_name_configuration = {
        existing = { name = "existing-hostname", gateway_name = "existing-gateway", api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/existing-rg/providers/Microsoft.ApiManagement/service/existing-service" }
      }
      api_management_group = {
        existing = { name = "existing-group", api_management_name = "existing-service", resource_group_name = "existing-rg" }
      }
      api_management_product = {
        existing = { product_id = "existing-product", api_management_name = "existing-service", resource_group_name = "existing-rg" }
      }
      api_management_subscription = {
        existing = { subscription_id = "existing-subscription", api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/existing-rg/providers/Microsoft.ApiManagement/service/existing-service" }
      }
      api_management_user = {
        existing = { user_id = "existing-user", api_management_name = "existing-service", resource_group_name = "existing-rg" }
      }
      api_management_workspace = {
        existing = { name = "existing-workspace", api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000003/resourceGroups/existing-rg/providers/Microsoft.ApiManagement/service/existing-service" }
      }
    }
  }
  assert {
    condition = (
      local.combined_objects_api_management.local.existing.id == "resolved-service" &&
      local.combined_objects_api_management_api.local.existing.id == "resolved-api" &&
      local.combined_objects_api_management_api_version_set.local.existing.id == "resolved-version-set" &&
      local.combined_objects_api_management_gateway.local.existing.id == "resolved-gateway" &&
      local.combined_objects_api_management_gateway_host_name_configuration.local.existing.id == "resolved-hostname" &&
      local.combined_objects_api_management_group.local.existing.id == "resolved-group" &&
      local.combined_objects_api_management_product.local.existing.product_id == "existing-product" &&
      local.combined_objects_api_management_subscription.local.existing.subscription_id == "existing-subscription" &&
      local.combined_objects_api_management_user.local.existing.user_id == "existing-user" &&
      local.combined_objects_api_management_workspace.local.existing.id == "resolved-workspace" &&
      data.azurerm_api_management.data_sources_lookup["existing"].timeouts.read == "10m"
    )
    error_message = "All APIM provider lookups must populate the current landing zone while preserving logical identifiers and timeouts."
  }
}

run "explicit_ids_and_legacy_landingzone_maps_remain_supported" {
  command = plan
  module {
    source = "../"
  }
  variables {
    data_sources = {
      api_management = {
        explicit = { id = "explicit-service", name = "explicit-service", resource_group_name = "explicit-rg" }
        legacy   = { gateway = { id = "legacy-service", name = "legacy-service" } }
      }
    }
    remote_objects = {
      api_management = {
        remote = { gateway = { id = "remote-service", name = "remote-service" } }
      }
    }
  }
  assert {
    condition = (
      length(data.azurerm_api_management.data_sources_lookup) == 0 &&
      local.combined_objects_api_management.local.explicit.id == "explicit-service" &&
      local.combined_objects_api_management.legacy.gateway.id == "legacy-service" &&
      local.combined_objects_api_management.remote.gateway.id == "remote-service"
    )
    error_message = "Explicit IDs must bypass lookups, and legacy landing-zone keyed entries and remote state must remain usable."
  }
}

run "unresolved_name_only_entries_are_not_combined" {
  command = plan
  module {
    source = "../"
  }
  variables {
    data_sources = {
      api_management = {
        incomplete = { name = "missing-resource-group" }
      }
    }
  }
  assert {
    condition = (
      length(data.azurerm_api_management.data_sources_lookup) == 0 &&
      !contains(keys(local.combined_objects_api_management.local), "incomplete") &&
      !contains(keys(local.combined_objects_api_management), "incomplete")
    )
    error_message = "Unresolved name-only entries must not leak into combined objects."
  }
}
