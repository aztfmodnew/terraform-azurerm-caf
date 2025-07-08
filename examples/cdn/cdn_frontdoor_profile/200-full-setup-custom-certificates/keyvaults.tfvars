keyvaults = {
  cdn_kv = {
    name                     = "cdn-frontdoor-kv"
    resource_group_key       = "cdn_rg"
    sku_name                 = "standard"
    soft_delete_enabled      = true
    purge_protection_enabled = false

    # Enable RBAC authorization instead of access policies
    enable_rbac_authorization = true

    tags = {
      purpose = "cdn-frontdoor"
    }
  }
}

# Certificate issuers configuration for DigiCert and GlobalSign
keyvault_certificate_issuers = {
  DigiCert = {
    issuer_name        = "DigiCert"
    provider_name      = "DigiCert"
    organization_id    = "your-digicert-org-id"     # Replace with your DigiCert organization ID
    account_id         = "your-digicert-account-id" # Replace with your DigiCert account ID
    resource_group_key = "cdn_rg"
    keyvault_key       = "cdn_kv"

    # Option 1: Reference to secret containing API key/password (recommended)
    cert_password_key = "digicert-api-key"

    # Option 2: Direct password (not recommended for production)
    # cert_issuer_password = "your-digicert-api-key"

    admin_settings = {
      admin1 = {
        first_name    = "Admin"
        last_name     = "User"
        email_address = "admin@yourcompany.com"
        phone         = "+1234567890"
      }
    }
  }
  GlobalSign = {
    issuer_name        = "GlobalSign"
    provider_name      = "GlobalSign"
    organization_id    = "your-globalsign-org-id"     # Replace with your GlobalSign organization ID
    account_id         = "your-globalsign-account-id" # Replace with your GlobalSign account ID
    resource_group_key = "cdn_rg"
    keyvault_key       = "cdn_kv"

    # Option 1: Reference to secret containing API key/password (recommended)
    cert_password_key = "globalsign-api-key"

    # Option 2: Direct password (not recommended for production)
    # cert_issuer_password = "your-globalsign-api-key"

    admin_settings = {
      admin1 = {
        first_name    = "Admin"
        last_name     = "User"
        email_address = "admin@yourcompany.com"
        phone         = "+1234567890"
      }
    }
  }
}

# Secrets for certificate issuer API keys (store securely)
dynamic_keyvault_secrets = {
  cdn_kv = {
    "digicert-api-key" = {
      secret_name = "digicert-api-key"
      value       = "your-actual-digicert-api-key" # Replace with your actual DigiCert API key
    }
    "globalsign-api-key" = {
      secret_name = "globalsign-api-key"
      value       = "your-actual-globalsign-api-key" # Replace with your actual GlobalSign API key
    }
  }
}

# Remove keyvault_access_policies - replaced by role_mapping below

keyvault_certificate_requests = {
  cdn_certificate = {
    name         = "cdn-certificate"
    keyvault_key = "cdn_kv"

    certificate_policy = {
      issuer_key_or_name  = "DigiCert"
      exportable          = true
      key_size            = 2048
      key_type            = "RSA"
      reuse_key           = true
      renewal_action      = "AutoRenew"
      lifetime_percentage = 90
      content_type        = "application/x-pkcs12"

      x509_certificate_properties = {
        extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
        key_usage = [
          "cRLSign",
          "dataEncipherment",
          "digitalSignature",
          "keyAgreement",
          "keyCertSign",
          "keyEncipherment",
        ]

        subject_alternative_names = {
          dns_names = ["example.com", "www.example.com"]
          emails    = []
          upns      = []
        }

        subject            = "CN=example.com"
        validity_in_months = 12
      }
    }

    tags = {
      purpose = "cdn-frontdoor-ssl"
    }
  }
}
