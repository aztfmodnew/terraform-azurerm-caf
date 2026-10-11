mock_provider "azurerm" {
  mock_resource "azurerm_databricks_access_connector" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Databricks/accessConnectors/dac-test"
      identity = {
        type         = "UserAssigned"
        identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dac-test"]
        principal_id = "00000000-0000-0000-0000-000000000001"
        tenant_id    = "00000000-0000-0000-0000-000000000002"
      }
    }
  }
}
variables {
  global_settings = {
    tags    = {}
    regions = { region1 = "australiaeast" }
  }
  client_config = { landingzone_key = "local" }
  resource_groups = {
    local = {
      dac_test = {
        name     = "test-rg"
        location = "australiaeast"
        tags     = {}
      }
    }
  }
  base_tags = false
  remote_objects = {
    managed_identities = {
      local = {
        dac_test = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dac-test"
        }
      }
    }
  }
}

run "identity_reference_and_timeouts_are_supported" {
  command = plan
  module {
    source = "../modules/analytics/databricks_access_connector"
  }
  variables {
    name = "dac-test"
    settings = {
      name               = "dac-test"
      resource_group_key = "dac_test"
      identity = {
        type                  = "UserAssigned"
        managed_identity_keys = ["dac_test"]
      }
      timeouts = {
        create = "45m"
        read   = "10m"
        update = "45m"
        delete = "45m"
      }
    }
  }
  assert {
    condition     = azurerm_databricks_access_connector.databricks_access_connector.identity[0].type == "UserAssigned" && azurerm_databricks_access_connector.databricks_access_connector.identity[0].identity_ids == toset([var.remote_objects.managed_identities.local.dac_test.id]) && output.identity[0].principal_id == "00000000-0000-0000-0000-000000000001" && output.identity[0].tenant_id == "00000000-0000-0000-0000-000000000002"
    error_message = "The access connector must resolve a managed identity key, expose its identity, and accept all supported timeout operations."
  }
}
