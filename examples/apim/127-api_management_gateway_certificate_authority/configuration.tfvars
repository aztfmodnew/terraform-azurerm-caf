global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "gateway-authority", region = "primary" }
}
managed_identities = {
  certificates = {
    name = "gateway-certificates", resource_group_key = "gateway"
  }
}
api_management = {
  gateway = {
    name           = "gateway-authority", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
    identity = {
      type = "UserAssigned", managed_identity_keys = ["certificates"]
    }
  }
}
api_management_gateway = {
  edge = {
    name          = "edge", api_management = { key = "gateway" }, resource_group = { key = "gateway" }
    description   = "Example self-hosted gateway registration."
    location_data = { name = "Example edge", city = "Amsterdam", region = "North Holland" }
  }
}
keyvaults = {
  certificates = {
    name                       = "gateway-ca", resource_group_key = "gateway", sku_name = "standard"
    rbac_authorization_enabled = false
    creation_policies = {
      logged_in_user = {
        certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover"]
        secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
      }
      logged_in_aad_app = {
        certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover"]
        secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
      }
    }
  }
}
keyvault_access_policies = {
  certificates = {
    apim = {
      managed_identity_key    = "certificates"
      certificate_permissions = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
    }
  }
}
keyvault_certificates = {
  authority = {
    keyvault_key              = "certificates", name = "backend-authority", subject = "CN=Example backend authority"
    issuer_parameters         = "Self", validity_in_months = 12
    exportable                = true, key_size = 2048, key_type = "RSA", reuse_key = false
    action_type               = "AutoRenew", days_before_expiry = 30, content_type = "application/x-pkcs12"
    key_usage                 = ["digitalSignature", "keyCertSign", "cRLSign"]
    subject_alternative_names = { dns_names = ["backend.example.com"] }
  }
}
api_management_certificate = {
  authority = {
    name                      = "backend-authority", api_management = { key = "gateway" }, resource_group = { key = "gateway" }
    key_vault_secret          = { certificate_key = "authority" }
    key_vault_identity_client = { key = "certificates" }
  }
}

api_management_gateway_certificate_authority = {
  backend = {
    api_management = { key = "gateway" }
    gateway        = { key = "edge" }
    certificate    = { key = "authority" }
    is_trusted     = true
  }
}
