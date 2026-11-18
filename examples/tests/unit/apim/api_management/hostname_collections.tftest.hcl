mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-apim" }
  }
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
  base_tags           = false
  vnets               = {}
  resource_group      = { name = "example-rg", location = "westeurope" }
  resource_group_name = "example-rg"
  location            = "westeurope"
}

run "all_inline_hostname_collections_preserve_endpoint_fields" {
  command = plan

  module {
    source = "../modules/apim/api_management"
  }

  variables {
    settings = {
      name            = "example-apim"
      publisher_name  = "Example"
      publisher_email = "api@example.com"
      sku_name        = "Premium_1"
      certificates = {
        root = {
          encoded_certificate = "example-certificate-data"
          store_name          = "Root"
        }
      }
      hostname_configuration = {
        managements = {
          first = {
            host_name                       = "management-one.example.com"
            certificate                     = "certificate-data"
            certificate_password            = "certificate-password"
            negotiate_client_certificate    = false
            ssl_keyvault_identity_client_id = "00000000-0000-0000-0000-000000000001"
          }
          second = {
            host_name                = "management-two.example.com"
            key_vault_certificate_id = "https://example.vault.azure.net/secrets/management"
          }
        }
        portals = {
          first  = { host_name = "portal-one.example.com", certificate = "portal-certificate", certificate_password = "portal-password", negotiate_client_certificate = true, ssl_keyvault_identity_client_id = "00000000-0000-0000-0000-000000000002" }
          second = { host_name = "portal-two.example.com", key_vault_id = "https://example.vault.azure.net/secrets/portal" }
        }
        developer_portals = {
          first  = { host_name = "developer-one.example.com", certificate = "developer-certificate", certificate_password = "developer-password", negotiate_client_certificate = false, ssl_keyvault_identity_client_id = "00000000-0000-0000-0000-000000000003" }
          second = { host_name = "developer-two.example.com", key_vault_certificate_id = "https://example.vault.azure.net/secrets/developer" }
        }
        proxies = {
          first  = { host_name = "gateway-one.example.com", certificate = "gateway-certificate", certificate_password = "gateway-password", negotiate_client_certificate = true, default_ssl_binding = false, ssl_keyvault_identity_client_id = "00000000-0000-0000-0000-000000000004" }
          second = { host_name = "gateway-two.example.com", key_vault_certificate_id = "https://example.vault.azure.net/secrets/gateway", default_ssl_binding = true }
        }
        scms = {
          first  = { host_name = "scm-one.example.com", certificate = "scm-certificate", certificate_password = "scm-password", negotiate_client_certificate = false, ssl_keyvault_identity_client_id = "00000000-0000-0000-0000-000000000005" }
          second = { host_name = "scm-two.example.com", key_vault_certificate_id = "https://example.vault.azure.net/secrets/scm" }
        }
      }
    }
  }

  assert {
    condition = (
      length(one(azurerm_api_management.apim.hostname_configuration).management) == 2 &&
      length(one(azurerm_api_management.apim.hostname_configuration).portal) == 2 &&
      length(one(azurerm_api_management.apim.hostname_configuration).developer_portal) == 2 &&
      length(one(azurerm_api_management.apim.hostname_configuration).proxy) == 2 &&
      length(one(azurerm_api_management.apim.hostname_configuration).scm) == 2
    )
    error_message = "All five inline hostname endpoint types must support repeated blocks."
  }

  assert {
    condition = alltrue([
      for endpoint in one(azurerm_api_management.apim.hostname_configuration).management :
      endpoint.host_name != "management-one.example.com" || (
        endpoint.certificate == "certificate-data" &&
        endpoint.certificate_password == "certificate-password" &&
        endpoint.negotiate_client_certificate == false &&
        endpoint.ssl_keyvault_identity_client_id == "00000000-0000-0000-0000-000000000001"
      )
    ])
    error_message = "Management endpoint fields must survive typed collection conversion."
  }

  assert {
    condition = (
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).portal : endpoint if endpoint.host_name == "portal-one.example.com"]).certificate_password == "portal-password" &&
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).portal : endpoint if endpoint.host_name == "portal-two.example.com"]).key_vault_certificate_id == "https://example.vault.azure.net/secrets/portal" &&
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).developer_portal : endpoint if endpoint.host_name == "developer-one.example.com"]).ssl_keyvault_identity_client_id == "00000000-0000-0000-0000-000000000003" &&
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).developer_portal : endpoint if endpoint.host_name == "developer-two.example.com"]).key_vault_certificate_id == "https://example.vault.azure.net/secrets/developer" &&
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).proxy : endpoint if endpoint.host_name == "gateway-one.example.com"]).default_ssl_binding == false &&
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).proxy : endpoint if endpoint.host_name == "gateway-two.example.com"]).default_ssl_binding &&
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).scm : endpoint if endpoint.host_name == "scm-one.example.com"]).negotiate_client_certificate == false &&
      one([for endpoint in one(azurerm_api_management.apim.hostname_configuration).scm : endpoint if endpoint.host_name == "scm-two.example.com"]).key_vault_certificate_id == "https://example.vault.azure.net/secrets/scm"
    )
    error_message = "Repeated endpoints must preserve certificate aliases, identity IDs and explicit boolean values."
  }

  assert {
    condition = (
      one(output.certificates).encoded_certificate == "example-certificate-data" &&
      alltrue([for field in ["expiry", "subject", "thumbprint"] : contains(keys(one(output.certificates)), field)]) &&
      length(one(output.hostname_configuration).proxy) == 2 &&
      alltrue([for field in ["certificate_source", "certificate_status", "expiry", "subject", "thumbprint"] : contains(keys(one(output.hostname_configuration).proxy[0]), field)])
    )
    error_message = "Certificate and hostname outputs must expose the full configured blocks and computed certificate metadata."
  }
}

run "collections_combine_with_singular_and_legacy_hostname_inputs" {
  command = plan

  module {
    source = "../modules/apim/api_management"
  }

  variables {
    settings = {
      name            = "example-apim"
      publisher_name  = "Example"
      publisher_email = "api@example.com"
      sku_name        = "Premium_1"
      management      = { host_name = "ignored-management.example.com", certificate = "ignored" }
      portal          = { host_name = "legacy-portal.example.com", certificate = "legacy" }
      proxy           = { host_name = "legacy-gateway.example.com", certificate = "legacy" }
      hostname_configuration = {
        management  = { host_name = "nested-management.example.com", certificate = "nested" }
        managements = { extra = { host_name = "extra-management.example.com", certificate = "extra" } }
        portals     = { extra = { host_name = "extra-portal.example.com", certificate = "extra" } }
        proxies     = { extra = { host_name = "extra-gateway.example.com", certificate = "extra" } }
      }
    }
  }

  assert {
    condition = (
      toset([for endpoint in one(azurerm_api_management.apim.hostname_configuration).management : endpoint.host_name]) == toset(["nested-management.example.com", "extra-management.example.com"]) &&
      toset([for endpoint in one(azurerm_api_management.apim.hostname_configuration).portal : endpoint.host_name]) == toset(["legacy-portal.example.com", "extra-portal.example.com"]) &&
      toset([for endpoint in one(azurerm_api_management.apim.hostname_configuration).proxy : endpoint.host_name]) == toset(["legacy-gateway.example.com", "extra-gateway.example.com"])
    )
    error_message = "Collections must append endpoints without changing nested-singular precedence or legacy top-level fallbacks."
  }
}

run "null_hostname_collections_are_empty" {
  command = plan

  module {
    source = "../modules/apim/api_management"
  }

  variables {
    settings = {
      name            = "example-apim"
      publisher_name  = "Example"
      publisher_email = "api@example.com"
      sku_name        = "Premium_1"
      hostname_configuration = {
        managements       = null
        portals           = null
        developer_portals = null
        proxies           = null
        scms              = null
        proxy             = { host_name = "required-gateway.example.com", certificate = "gateway-certificate" }
      }
    }
  }

  assert {
    condition = (
      length(one(azurerm_api_management.apim.hostname_configuration).management) == 0 &&
      length(one(azurerm_api_management.apim.hostname_configuration).portal) == 0 &&
      length(one(azurerm_api_management.apim.hostname_configuration).developer_portal) == 0 &&
      length(one(azurerm_api_management.apim.hostname_configuration).proxy) == 1 &&
      one(one(azurerm_api_management.apim.hostname_configuration).proxy).host_name == "required-gateway.example.com" &&
      length(one(azurerm_api_management.apim.hostname_configuration).scm) == 0
    )
    error_message = "Explicit-null hostname collections must normalize to empty collections."
  }
}
