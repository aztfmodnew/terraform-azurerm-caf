mock_provider "azurerm" {}

variables {
  global_settings = {
    tags = {}
  }
  base_tags = false
  resource_group = {
    name = "test-rg"
    tags = {}
  }
  resource_group_name = null
}

run "directory_accepts_all_timeout_operations" {
  command = plan

  module {
    source = "../modules/aadb2c/aadb2c_directory"
  }

  variables {
    settings = {
      country_code            = "ES"
      data_residency_location = "Europe"
      display_name            = "example-b2c"
      domain_name             = "exampleb2c.onmicrosoft.com"
      sku_name                = "PremiumP1"
      tags                    = { environment = "dev" }
      timeouts = {
        create = "45m"
        read   = "10m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition     = azurerm_aadb2c_directory.aadb2c.timeouts.create == "45m" && azurerm_aadb2c_directory.aadb2c.timeouts.read == "10m" && azurerm_aadb2c_directory.aadb2c.timeouts.update == "45m" && azurerm_aadb2c_directory.aadb2c.timeouts.delete == "45m"
    error_message = "All supported AAD B2C directory timeout operations must be passed through."
  }

  assert {
    condition     = azurerm_aadb2c_directory.aadb2c.resource_group_name == "test-rg" && azurerm_aadb2c_directory.aadb2c.tags["environment"] == "dev"
    error_message = "The directory must fall back to the resource-group object and pass settings tags through."
  }
}

run "directory_without_timeouts_is_supported" {
  command = plan

  module {
    source = "../modules/aadb2c/aadb2c_directory"
  }

  variables {
    settings = {
      data_residency_location = "Europe"
      domain_name             = "exampleb2c.onmicrosoft.com"
      sku_name                = "PremiumP2"
    }
  }

  assert {
    condition     = azurerm_aadb2c_directory.aadb2c.timeouts == null
    error_message = "The timeouts block must stay absent when no timeouts are configured."
  }
}
