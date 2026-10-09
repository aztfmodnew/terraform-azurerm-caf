mock_provider "azurerm" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

variables {
  global_settings = { prefixes = [], random_length = 0, passthrough = false, use_slug = true }
  client_config   = { landingzone_key = "local" }
  remote_objects = {
    data_factory = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.DataFactory/factories/test"
    }
    databricks_workspace = {
      id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Databricks/workspaces/remote"
      workspace_url = "adb-test.azuredatabricks.net"
    }
  }
}

run "legacy_workspace_id_alias" {
  command = plan
  module {
    source = "../modules/data_factory/linked_services/azure_databricks"
  }
  variables {
    settings = {
      name                       = "legacy"
      existing_cluster_id        = "0123-456789-test123"
      msi_work_space_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Databricks/workspaces/legacy"
    }
  }
  assert {
    condition     = azurerm_data_factory_linked_service_azure_databricks.dflsad.msi_workspace_id == var.settings.msi_work_space_resource_id
    error_message = "The legacy MSI workspace ID must map to the current provider argument."
  }
}
run "current_workspace_id_precedence" {
  command = plan
  module {
    source = "../modules/data_factory/linked_services/azure_databricks"
  }
  variables {
    settings = {
      name                       = "current"
      existing_cluster_id        = "0123-456789-test123"
      msi_work_space_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Databricks/workspaces/legacy"
      msi_workspace_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.Databricks/workspaces/current"
    }
  }
  assert {
    condition     = azurerm_data_factory_linked_service_azure_databricks.dflsad.msi_workspace_id == var.settings.msi_workspace_id
    error_message = "The current MSI workspace ID must take precedence over its legacy alias."
  }
}
run "remote_workspace_id_fallback" {
  command = plan
  module {
    source = "../modules/data_factory/linked_services/azure_databricks"
  }
  variables {
    settings = { name = "remote", existing_cluster_id = "0123-456789-test123" }
  }
  assert {
    condition     = azurerm_data_factory_linked_service_azure_databricks.dflsad.msi_workspace_id == var.remote_objects.databricks_workspace.id
    error_message = "Existing CAF workspace references must retain their remote-object ID fallback."
  }
}
