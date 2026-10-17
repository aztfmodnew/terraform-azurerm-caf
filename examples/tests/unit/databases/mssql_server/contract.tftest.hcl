# Opt-in, plan-only contracts; no Azure credentials or calls.
# From the repository root:
# terraform -chdir=examples init -backend=false -test-directory=tests/unit/databases/mssql_server
# terraform -chdir=examples test -test-directory=tests/unit/databases/mssql_server -no-color
mock_provider "azurerm" {
  mock_resource "azurerm_mssql_server" {
    override_during = plan
    defaults = {
      # Optional+Computed: a provider result proves the configured login was unset.
      administrator_login = "provider-generated-login"
    }
  }
}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "contract-sql" }
  }
}
mock_provider "random" {
  mock_resource "random_password" {
    override_during = plan
    defaults        = { result = "Mock-generated-only-251!" }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
  }
  client_config       = { landingzone_key = "local" }
  location            = "westeurope"
  resource_group_name = "contract-rg"
  resource_group      = { name = "contract-rg", location = "westeurope" }
  base_tags           = false
  storage_accounts    = {}
  azuread_groups      = {}
  vnets               = {}
  private_endpoints   = {}
  resource_groups     = {}
  remote_objects      = {}
  keyvault_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/contract-rg/providers/Microsoft.KeyVault/vaults/contract-vault"
}

run "entra_only_needs_no_sql_credentials_or_vault" {
  command = plan
  module {
    source = "../modules/databases/mssql_server"
  }
  variables {
    keyvault_id = null
    settings = {
      name = "contract-sql"
      azuread_administrator = {
        azuread_authentication_only = true
        login_username              = "entra-admin"
        object_id                   = "00000000-0000-0000-0000-000000000251"
        tenant_id                   = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  assert {
    condition     = length(random_password.sql_admin) == 0 && length(azurerm_key_vault_secret.sql_admin_password) == 0
    error_message = "Entra-only authentication must create neither password helper."
  }
  assert {
    condition     = azurerm_mssql_server.mssql.administrator_login == "provider-generated-login" && azurerm_mssql_server.mssql.administrator_login_password == null
    error_message = "Entra-only authentication must leave SQL credentials unset (login is provider-computed)."
  }
  assert {
    condition = (
      azurerm_mssql_server.mssql.azuread_administrator[0].azuread_authentication_only == true &&
      azurerm_mssql_server.mssql.azuread_administrator[0].login_username == "entra-admin" &&
      azurerm_mssql_server.mssql.azuread_administrator[0].object_id == "00000000-0000-0000-0000-000000000251" &&
      azurerm_mssql_server.mssql.azuread_administrator[0].tenant_id == "00000000-0000-0000-0000-000000000000"
    )
    error_message = "Entra administrator settings must remain intact."
  }
}

run "entra_only_ignores_explicit_sql_credentials" {
  command = plan
  module {
    source = "../modules/databases/mssql_server"
  }
  variables {
    keyvault_id = null
    settings = {
      name                         = "contract-sql"
      administrator_login          = "ignored-sql-admin"
      administrator_login_password = "Mock-explicit-only-251!"
      azuread_administrator = {
        azuread_authentication_only = true
        login_username              = "entra-admin"
        object_id                   = "00000000-0000-0000-0000-000000000251"
        tenant_id                   = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  assert {
    condition     = length(random_password.sql_admin) == 0 && length(azurerm_key_vault_secret.sql_admin_password) == 0
    error_message = "Explicit SQL credentials must not enable helpers in Entra-only mode."
  }
  assert {
    condition     = azurerm_mssql_server.mssql.administrator_login == "provider-generated-login" && azurerm_mssql_server.mssql.administrator_login_password == null
    error_message = "Entra-only authentication must ignore explicit SQL credentials."
  }
}

run "sql_auth_omitted_flag_generates_and_connects_password" {
  command = plan
  module {
    source = "../modules/databases/mssql_server"
  }
  variables {
    settings = {
      name                = "contract-sql"
      administrator_login = "sql-admin"
    }
  }
  assert {
    condition     = length(random_password.sql_admin) == 1 && length(azurerm_key_vault_secret.sql_admin_password) == 1
    error_message = "SQL authentication without a password must retain both helpers."
  }
  assert {
    condition = (
      azurerm_mssql_server.mssql.administrator_login == "sql-admin" &&
      azurerm_mssql_server.mssql.administrator_login_password == random_password.sql_admin[0].result &&
      azurerm_key_vault_secret.sql_admin_password[0].value == random_password.sql_admin[0].result &&
      azurerm_key_vault_secret.sql_admin_password[0].key_vault_id == var.keyvault_id
    )
    error_message = "The generated password must flow through the vault secret to the SQL server."
  }
}

run "sql_auth_false_flag_null_password_generates_and_connects_password" {
  command = plan
  module {
    source = "../modules/databases/mssql_server"
  }
  variables {
    settings = {
      name                         = "contract-sql"
      administrator_login          = "sql-admin"
      administrator_login_password = null
      azuread_administrator = {
        azuread_authentication_only = false
        login_username              = "entra-admin"
        object_id                   = "00000000-0000-0000-0000-000000000251"
        tenant_id                   = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
  assert {
    condition     = length(random_password.sql_admin) == 1 && length(azurerm_key_vault_secret.sql_admin_password) == 1
    error_message = "Explicit false and a null password must preserve SQL password generation."
  }
  assert {
    condition = (
      azurerm_mssql_server.mssql.administrator_login == "sql-admin" &&
      azurerm_mssql_server.mssql.administrator_login_password == random_password.sql_admin[0].result &&
      azurerm_key_vault_secret.sql_admin_password[0].value == random_password.sql_admin[0].result &&
      azurerm_key_vault_secret.sql_admin_password[0].key_vault_id == var.keyvault_id &&
      azurerm_mssql_server.mssql.azuread_administrator[0].azuread_authentication_only == false
    )
    error_message = "A null password must use the generated vault secret without enabling Entra-only authentication."
  }
}

run "sql_auth_explicit_password_skips_helpers" {
  command = plan
  module {
    source = "../modules/databases/mssql_server"
  }
  variables {
    keyvault_id = null
    settings = {
      name                         = "contract-sql"
      administrator_login          = "sql-admin"
      administrator_login_password = "Mock-explicit-only-251!"
    }
  }
  assert {
    condition     = length(random_password.sql_admin) == 0 && length(azurerm_key_vault_secret.sql_admin_password) == 0
    error_message = "An explicit SQL password must skip both helpers."
  }
  assert {
    condition     = azurerm_mssql_server.mssql.administrator_login == "sql-admin" && azurerm_mssql_server.mssql.administrator_login_password == var.settings.administrator_login_password
    error_message = "Explicit SQL credentials must be passed to the server unchanged."
  }
}
