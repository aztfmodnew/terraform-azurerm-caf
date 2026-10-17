# Root wiring coverage; run from the repository root so Azure/azapi resolves correctly:
# terraform init -backend=false -test-directory=examples/tests/unit/databases/mssql_server/root
# terraform test -test-directory=examples/tests/unit/databases/mssql_server/root -no-color
# All providers are mocked and every run is plan-only.
mock_provider "azurerm" {
  source = "./examples/tests/mock_data"
}
mock_provider "azurerm" {
  alias  = "vhub"
  source = "./examples/tests/mock_data"
}
mock_provider "azuread" {
  source = "./examples/tests/mock_data"
}
mock_provider "azapi" {
  source = "./examples/tests/mock_data"
}
mock_provider "external" {
  source = "./examples/tests/mock_data"
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "contract-sql" }
  }
}
mock_provider "random" {}
mock_provider "null" {}
mock_provider "time" {}
mock_provider "tls" {}
mock_provider "local" {}

variables {
  global_settings = {
    default_region = "region1"
    regions        = { region1 = "westeurope" }
    random_length  = 0
  }
  resource_groups = {
    contract = { name = "contract-rg" }
  }
}

run "root_entra_only_without_vault" {
  command = plan
  module {
    source = "./"
  }
  variables {
    database = {
      mssql_servers = {
        contract = {
          name               = "contract-sql"
          resource_group_key = "contract"
          azuread_administrator = {
            azuread_authentication_only = true
            login_username              = "entra-admin"
            object_id                   = "00000000-0000-0000-0000-000000000251"
            tenant_id                   = "00000000-0000-0000-0000-000000000000"
          }
        }
      }
    }
  }
  assert {
    condition = (
      output.mssql_servers["contract"].azuread_administrator[0].azuread_authentication_only == true &&
      output.mssql_servers["contract"].azuread_administrator[0].login_username == "entra-admin" &&
      output.mssql_servers["contract"].azuread_administrator[0].object_id == "00000000-0000-0000-0000-000000000251"
    )
    error_message = "Root must plan Entra-only SQL without any vault or SQL credentials and retain its administrator."
  }
}

run "root_entra_only_bypasses_invalid_unused_vault" {
  command = plan
  module {
    source = "./"
  }
  variables {
    database = {
      mssql_servers = {
        contract = {
          name                         = "contract-sql"
          resource_group_key           = "contract"
          administrator_login_password = null
          keyvault                     = { lz_key = "missing-zone", key = "missing-vault" }
          azuread_administrator = {
            azuread_authentication_only = true
            login_username              = "entra-admin"
            object_id                   = "00000000-0000-0000-0000-000000000251"
            tenant_id                   = "00000000-0000-0000-0000-000000000000"
          }
        }
      }
    }
  }
  assert {
    condition     = output.mssql_servers["contract"].azuread_administrator[0].azuread_authentication_only == true
    error_message = "Entra-only root wiring must not evaluate even an invalid unused vault reference."
  }
}

run "root_sql_auth_null_password_resolves_vault" {
  command = plan
  module {
    source = "./"
  }
  variables {
    data_sources = {
      keyvaults = {
        contract = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/contract-rg/providers/Microsoft.KeyVault/vaults/contract-vault"
        }
      }
    }
    database = {
      mssql_servers = {
        contract = {
          name                         = "contract-sql"
          resource_group_key           = "contract"
          administrator_login          = "sql-admin"
          administrator_login_password = null
          keyvault_key                 = "contract"
          azuread_administrator = {
            azuread_authentication_only = false
            login_username              = "entra-admin"
            object_id                   = "00000000-0000-0000-0000-000000000251"
            tenant_id                   = "00000000-0000-0000-0000-000000000000"
          }
        }
      }
    }
  }
  assert {
    condition     = output.mssql_servers["contract"].azuread_administrator[0].azuread_authentication_only == false
    error_message = "SQL auth with a null password must resolve the vault required by password generation."
  }
}

run "root_sql_auth_explicit_password_needs_no_vault" {
  command = plan
  module {
    source = "./"
  }
  variables {
    database = {
      mssql_servers = {
        contract = {
          name                         = "contract-sql"
          resource_group_key           = "contract"
          administrator_login          = "sql-admin"
          administrator_login_password = "Mock-explicit-only-251!"
        }
      }
    }
  }
  assert {
    condition     = output.mssql_servers["contract"].name == "contract-sql"
    error_message = "Root must retain explicit-password SQL authentication without looking up a vault."
  }
}
