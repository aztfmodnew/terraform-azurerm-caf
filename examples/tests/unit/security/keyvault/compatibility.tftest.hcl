mock_provider "azurerm" {
  mock_resource "azurerm_key_vault" {
    defaults = {
      id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.KeyVault/vaults/migrationtest"
      vault_uri = "https://migrationtest.vault.azure.net/"
    }
  }
}
mock_provider "azuread" {}
mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    defaults = { result = "migrationtest" }
  }
}

variables {
  global_settings = {
    prefixes       = []
    random_length  = 0
    passthrough    = true
    use_slug       = false
    environment    = "test"
    default_region = "region1"
    regions        = { region1 = "westeurope" }
  }
  client_config = {
    landingzone_key = "local"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
  }
  location            = "westeurope"
  resource_group_name = "migrationtest"
  resource_group      = { name = "migrationtest", location = "westeurope", tags = {} }
  base_tags           = false
  remote_objects      = {}
  private_endpoints   = {}
  resource_groups     = {}
  vnets               = {}
  diagnostics         = { diagnostics_definition = {} }
}

run "keyvault_contacts_preserve_input_shape" {
  command = plan
  module {
    source = "../modules/security/keyvault"
  }
  variables {
    settings = {
      name     = "migrationtest"
      contacts = { owner = { email = "owner@example.com", name = "Owner", phone = "+123456789" } }
    }
  }
  assert {
    condition     = one(azurerm_key_vault_certificate_contacts.contacts["contacts"].contact).email == "owner@example.com" && one(azurerm_key_vault_certificate_contacts.contacts["contacts"].contact).name == "Owner"
    error_message = "Existing Key Vault contacts must retain their input shape and values."
  }
}
run "keyvault_null_contacts_create_no_resource" {
  command = plan
  module {
    source = "../modules/security/keyvault"
  }
  variables {
    settings = { name = "migrationtest", contacts = null }
  }
  assert {
    condition     = length(azurerm_key_vault_certificate_contacts.contacts) == 0
    error_message = "Null contacts must not create a certificate-contacts resource."
  }
}
