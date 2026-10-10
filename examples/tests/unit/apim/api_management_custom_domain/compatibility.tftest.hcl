mock_provider "azurerm" {}

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
  base_tags           = {}
  remote_objects      = {}
  private_endpoints   = {}
  resource_groups     = {}
  vnets               = {}
  diagnostics         = { diagnostics_definition = {} }
}

run "apim_custom_domain_legacy_remote_certificate" {
  command = plan
  module {
    source = "../modules/apim/api_management_custom_domain"
  }
  variables {
    base_tags         = {}
    api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ApiManagement/service/test"
    remote_objects = {
      keyvault_certificates = { local = { cert = { secret_id = "https://migrationtest.vault.azure.net/secrets/cert" } } }
    }
    settings = {
      gateways = [{ host_name = "api.example.com", key_vault_certificate = { certificate_key = "cert" } }]
    }
  }
  assert {
    condition     = one(azurerm_api_management_custom_domain.apim.gateway).key_vault_certificate_id == "https://migrationtest.vault.azure.net/secrets/cert"
    error_message = "Legacy same-landing-zone certificate lookup must resolve to its secret URI."
  }
}

run "apim_custom_domain_all_endpoint_options" {
  command = plan
  module {
    source = "../modules/apim/api_management_custom_domain"
  }
  variables {
    api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ApiManagement/service/test"
    remote_objects = {
      keyvault_certificates = {
        local = {
          cert = { secret_id = "https://migrationtest.vault.azure.net/secrets/cert" }
        }
        remote = {
          portal_cert = { secret_id = "https://remote.vault.azure.net/secrets/portal" }
        }
      }
      keyvault_certificate_requests = {
        remote = {
          request  = { secret_id = "https://remote.vault.azure.net/secrets/request" }
          scm_cert = { secret_id = "https://remote.vault.azure.net/secrets/scm" }
        }
      }
      managed_identities = {
        local = {
          identity = { client_id = "00000000-0000-0000-0000-000000000001" }
        }
        remote = {
          identity = { client_id = "00000000-0000-0000-0000-000000000002" }
        }
      }
    }
    settings = {
      developer_portal = {
        host_name             = "portal.example.com"
        key_vault_certificate = { certificate_key = "cert" }
        managed_identity      = { key = "identity" }
      }
      developer_portals = {
        secondary = { host_name = "portal2.example.com", certificate = "base64-certificate", certificate_password = "password" }
      }
      management = {
        host_name                       = "management.example.com"
        key_vault_id                    = "https://management.vault.azure.net/secrets/cert"
        ssl_keyvault_identity_client_id = "00000000-0000-0000-0000-000000000003"
        negotiate_client_certificate    = true
      }
      portal = {
        host_name             = "portal.example.com"
        key_vault_certificate = { certificate_key = "portal_cert", lz_key = "remote" }
      }
      gateway = {
        host_name                    = "api.example.com"
        default_ssl_binding          = true
        certificate_request_key      = "request"
        lz_key                       = "remote"
        managed_identity             = { key = "identity", lz_key = "remote" }
        negotiate_client_certificate = true
      }
      scm = {
        host_name               = "scm.example.com"
        certificate_request_key = "scm_cert"
        keyvault                = { lz_key = "remote" }
      }
      timeouts = {
        create = "60m"
        read   = "5m"
        update = "60m"
        delete = "60m"
      }
    }
  }
  assert {
    condition = (
      azurerm_api_management_custom_domain.apim.developer_portal[0].key_vault_certificate_id == "https://migrationtest.vault.azure.net/secrets/cert" &&
      azurerm_api_management_custom_domain.apim.developer_portal[0].ssl_keyvault_identity_client_id == "00000000-0000-0000-0000-000000000001" &&
      length(azurerm_api_management_custom_domain.apim.developer_portal) == 2 &&
      one(azurerm_api_management_custom_domain.apim.management).key_vault_certificate_id == "https://management.vault.azure.net/secrets/cert" &&
      one(azurerm_api_management_custom_domain.apim.management).negotiate_client_certificate &&
      one(azurerm_api_management_custom_domain.apim.portal).key_vault_certificate_id == "https://remote.vault.azure.net/secrets/portal" &&
      one(azurerm_api_management_custom_domain.apim.gateway).key_vault_certificate_id == "https://remote.vault.azure.net/secrets/request" &&
      one(azurerm_api_management_custom_domain.apim.gateway).default_ssl_binding &&
      one(azurerm_api_management_custom_domain.apim.gateway).ssl_keyvault_identity_client_id == "00000000-0000-0000-0000-000000000002" &&
      one(azurerm_api_management_custom_domain.apim.scm).key_vault_certificate_id == "https://remote.vault.azure.net/secrets/scm" &&
      azurerm_api_management_custom_domain.apim.timeouts.update == "60m"
    )
    error_message = "All endpoint blocks must resolve certificates, managed identities, and endpoint-specific options consistently."
  }
}

run "apim_custom_domain_plural_endpoints" {
  command = plan
  module {
    source = "../modules/apim/api_management_custom_domain"
  }
  variables {
    api_management_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ApiManagement/service/test"
    settings = {
      managements = {
        management = { host_name = "management.example.com" }
      }
      portals = {
        portal = { host_name = "portal.example.com" }
      }
      gateways = {
        api  = { host_name = "api.example.com" }
        api2 = { host_name = "api2.example.com" }
      }
      scms = {
        scm = { host_name = "scm.example.com" }
      }
    }
  }
  assert {
    condition = (
      length(azurerm_api_management_custom_domain.apim.management) == 1 &&
      length(azurerm_api_management_custom_domain.apim.portal) == 1 &&
      length(azurerm_api_management_custom_domain.apim.gateway) == 2 &&
      length(azurerm_api_management_custom_domain.apim.scm) == 1
    )
    error_message = "Plural endpoint maps must generate every configured provider block."
  }
}
