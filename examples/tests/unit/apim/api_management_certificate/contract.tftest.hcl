mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-cert" }
  }
}

run "certificate_with_pfx_data_and_timeouts" {
  command = plan

  module {
    source = "../modules/apim/api_management_certificate"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name     = "example-cert"
      data     = "cGZ4LWRhdGE="
      password = "not-a-real-password"
      timeouts = {
        create = "40m"
        read   = "6m"
        update = "40m"
        delete = "40m"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_certificate.apim.data == "cGZ4LWRhdGE="
    error_message = "Base64 PFX data must be passed to the provider."
  }
  assert {
    condition     = azurerm_api_management_certificate.apim.password == "not-a-real-password"
    error_message = "The PFX password must be passed to the provider."
  }
  assert {
    condition     = azurerm_api_management_certificate.apim.name == "example-cert"
    error_message = "The certificate must use the CAF-generated name."
  }
  assert {
    condition     = azurerm_api_management_certificate.apim.timeouts.update == "40m"
    error_message = "Certificate timeouts must be passed to the provider."
  }
}

run "certificate_with_key_vault_references" {
  command = plan

  module {
    source = "../modules/apim/api_management_certificate"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config = { landingzone_key = "local" }
    base_tags     = {}
    remote_objects = {
      keyvault_certificates = {
        local = {
          cert1 = { secret_id = "https://example-vault.vault.azure.net/secrets/cert1" }
        }
      }
      keyvault_certificate_requests = {}
      managed_identities = {
        local = {
          mi1 = { client_id = "00000000-0000-0000-0000-000000000001" }
        }
      }
    }
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name = "example-cert"
      key_vault_secret = {
        certificate_key = "cert1"
      }
      key_vault_identity_client = {
        key = "mi1"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_certificate.apim.key_vault_secret_id == "https://example-vault.vault.azure.net/secrets/cert1"
    error_message = "The Key Vault certificate secret ID must resolve from remote_objects."
  }
  assert {
    condition     = azurerm_api_management_certificate.apim.key_vault_identity_client_id == "00000000-0000-0000-0000-000000000001"
    error_message = "The user-assigned identity client ID must resolve from remote_objects."
  }
}

run "certificate_request_with_remote_landing_zone" {
  command = plan

  module {
    source = "../modules/apim/api_management_certificate"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config = { landingzone_key = "local" }
    base_tags     = {}
    remote_objects = {
      keyvault_certificates = {}
      keyvault_certificate_requests = {
        remote = {
          request1 = { secret_id = "https://remote-vault.vault.azure.net/secrets/request1" }
        }
      }
      managed_identities = {}
    }
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name = "example-cert"
      key_vault_secret = {
        certificate_request_key = "request1"
        lz_key                  = "remote"
      }
      key_vault_identity_client = {
        id = "00000000-0000-0000-0000-000000000002"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_certificate.apim.key_vault_secret_id == "https://remote-vault.vault.azure.net/secrets/request1"
    error_message = "The certificate request secret ID must resolve from its remote landing zone."
  }
  assert {
    condition     = azurerm_api_management_certificate.apim.key_vault_identity_client_id == "00000000-0000-0000-0000-000000000002"
    error_message = "The certificate identity may be supplied by its direct client ID."
  }
}

run "certificate_with_legacy_key_vault_id" {
  command = plan

  module {
    source = "../modules/apim/api_management_certificate"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name         = "example-cert"
      key_vault_id = "https://example-vault.vault.azure.net/secrets/legacy-cert"
    }
  }

  assert {
    condition     = azurerm_api_management_certificate.apim.key_vault_secret_id == "https://example-vault.vault.azure.net/secrets/legacy-cert"
    error_message = "The historical key_vault_id setting must continue to populate key_vault_secret_id."
  }
}

run "certificate_source_must_be_exclusive" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_certificate"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name                = "example-cert"
      data                = "cGZ4LWRhdGE="
      key_vault_secret_id = "https://example-vault.vault.azure.net/secrets/cert1"
    }
  }
}

run "certificate_rejects_multiple_key_vault_sources" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_certificate"
  }

  variables {
    global_settings     = {}
    client_config       = { landingzone_key = "local" }
    base_tags           = {}
    remote_objects      = {}
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name                = "example-cert"
      key_vault_secret_id = "https://example-vault.vault.azure.net/secrets/cert1"
      key_vault_id        = "https://example-vault.vault.azure.net/secrets/legacy-cert"
    }
  }
}

run "certificate_explicit_ids_take_precedence_over_remote_objects" {
  command = plan

  module {
    source = "../modules/apim/api_management_certificate"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
      tags          = {}
    }
    client_config = { landingzone_key = "local" }
    base_tags     = {}
    remote_objects = {
      keyvault_certificates = {
        local = {
          cert1 = { secret_id = "https://example-vault.vault.azure.net/secrets/resolved-by-key" }
        }
      }
      managed_identities = {
        local = {
          mi1 = { client_id = "00000000-0000-0000-0000-000000000002" }
        }
      }
    }
    api_management_name = "example-apim"
    resource_group_name = "example-rg"
    settings = {
      name                         = "example-cert"
      key_vault_secret_id          = "https://example-vault.vault.azure.net/secrets/explicit"
      key_vault_identity_client_id = "00000000-0000-0000-0000-000000000001"
      key_vault_identity_client = {
        key = "mi1"
      }
    }
  }

  assert {
    condition     = azurerm_api_management_certificate.apim.key_vault_secret_id == "https://example-vault.vault.azure.net/secrets/explicit"
    error_message = "An explicit key_vault_secret_id must be used verbatim."
  }
  assert {
    condition     = azurerm_api_management_certificate.apim.key_vault_identity_client_id == "00000000-0000-0000-0000-000000000001"
    error_message = "An explicit key_vault_identity_client_id must take precedence over the key-based remote_objects lookup."
  }
}
