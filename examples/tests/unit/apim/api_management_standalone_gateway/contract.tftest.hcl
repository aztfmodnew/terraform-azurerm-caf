mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "caf-standalone" }
  }
}
variables {
  global_settings = { default_region = "primary", regions = { primary = "westeurope" }, tags = { inherited = "global", owner = "global" } }
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    resource_groups = {
      local  = { parent = { name = "local-rg", location = "westeurope", tags = { owner = "group" } } }
      remote = { parent = { name = "remote-rg", location = "northeurope", tags = { owner = "remote-group" } } }
    }
    vnets = {
      local  = { network = { subnets = { gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/local-network/subnets/gateway" } } } }
      remote = { network = { subnets = { gateway = { id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/remote-network/subnets/gateway" } } } }
    }
  }
}
run "local_network_capacity_default_and_no_tag_inheritance" {
  command = plan
  module { source = "../modules/apim/api_management_standalone_gateway" }
  variables {
    settings = { name = "gateway", resource_group = { key = "parent" }, subnet = { vnet_key = "network", key = "gateway" }, virtual_network_type = "External", sku = { name = "WorkspaceGatewayPremium" } }
  }
  assert {
    condition     = output.name == "caf-standalone" && output.resource_group_name == "local-rg" && output.location == "westeurope" && one(azurerm_api_management_standalone_gateway.resource.sku).capacity == 1 && endswith(azurerm_api_management_standalone_gateway.resource.backend_subnet_id, "/virtualNetworks/local-network/subnets/gateway") && !contains(keys(azurerm_api_management_standalone_gateway.resource.tags), "inherited") && azurecaf_name.resource.resource_type == "azurerm_api_management"
    error_message = "Local subnet resolution, capacity default, opt-in tag inheritance and supported fallback CAF type must be used."
  }
}
run "remote_network_and_tag_precedence" {
  command = plan
  module { source = "../modules/apim/api_management_standalone_gateway" }
  variables {
    base_tags = true
    settings  = { name = "gateway", resource_group = { key = "parent", lz_key = "remote" }, subnet = { vnet_key = "network", key = "gateway", lz_key = "remote" }, virtual_network_type = "Internal", sku = { name = "WorkspaceGatewayPremium", capacity = 2 }, tags = { owner = "settings" }, timeouts = { create = "40m", read = "6m", update = "41m", delete = "42m" } }
  }
  assert {
    condition     = output.resource_group_name == "remote-rg" && output.location == "northeurope" && endswith(azurerm_api_management_standalone_gateway.resource.backend_subnet_id, "/virtualNetworks/remote-network/subnets/gateway") && one(azurerm_api_management_standalone_gateway.resource.sku).capacity == 2 && azurerm_api_management_standalone_gateway.resource.tags.owner == "settings" && azurerm_api_management_standalone_gateway.resource.tags.inherited == "global" && azurerm_api_management_standalone_gateway.resource.virtual_network_type == "Internal" && azurerm_api_management_standalone_gateway.resource.timeouts.update == "41m"
    error_message = "Remote subnet/group, group location, explicit SKU, merged tags, network type and timeouts must be preserved."
  }
}
run "direct_values_and_null_capacity_default" {
  command = plan
  module { source = "../modules/apim/api_management_standalone_gateway" }
  variables {
    settings = { name = "gateway", resource_group_name = "direct-rg", location = "eastus", virtual_network_type = "External", backend_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/direct-network/subnets/gateway", resource_group = { key = "missing" }, subnet = { vnet_key = "missing", key = "missing" }, sku = { name = "WorkspaceGatewayPremium", capacity = null }, tags = null, timeouts = null }
  }
  assert {
    condition     = output.resource_group_name == "direct-rg" && output.location == "eastus" && one(azurerm_api_management_standalone_gateway.resource.sku).capacity == 1 && endswith(azurerm_api_management_standalone_gateway.resource.backend_subnet_id, "/virtualNetworks/direct-network/subnets/gateway")
    error_message = "Direct values must override missing references and explicit null capacity must use one."
  }
}
run "reject_network_type_without_subnet" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_standalone_gateway" }
  variables {
    settings = { name = "gateway", resource_group_name = "direct-rg", location = "eastus", virtual_network_type = "External", sku = { name = "WorkspaceGatewayPremium" } }
  }
}
run "reject_subnet_without_network_type" {
  command         = plan
  expect_failures = [var.settings]
  module { source = "../modules/apim/api_management_standalone_gateway" }
  variables {
    settings = { name = "gateway", resource_group_name = "direct-rg", location = "eastus", subnet = { vnet_key = "network", key = "gateway" }, sku = { name = "WorkspaceGatewayPremium" } }
  }
}
