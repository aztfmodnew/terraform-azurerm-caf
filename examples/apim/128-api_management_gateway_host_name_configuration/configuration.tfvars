global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "gateway-hostname", region = "primary" }
}
managed_identities = {
  certificates = {
    name = "gateway-certificates", resource_group_key = "gateway"
  }
}
api_management = {
  gateway = {
    name           = "gateway-hostname", region = "primary", resource_group = { key = "gateway" }
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
    name                       = "gateway-tls", resource_group_key = "gateway", sku_name = "standard"
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
  tls = {
    keyvault_key              = "certificates", name = "edge-tls", subject = "CN=api.example.com"
    issuer_parameters         = "Self", validity_in_months = 12
    exportable                = true, key_size = 2048, key_type = "RSA", reuse_key = false
    action_type               = "AutoRenew", days_before_expiry = 30, content_type = "application/x-pkcs12"
    key_usage                 = ["digitalSignature", "keyEncipherment"]
    subject_alternative_names = { dns_names = ["api.example.com"] }
  }
}
api_management_certificate = {
  tls = {
    name                      = "edge-tls", api_management = { key = "gateway" }, resource_group = { key = "gateway" }
    key_vault_secret          = { certificate_key = "tls" }
    key_vault_identity_client = { key = "certificates" }
  }
}

api_management_gateway_host_name_configuration = {
  edge = {
    name                               = "edge-host"
    host_name                          = "api.example.com"
    api_management                     = { key = "gateway" }
    gateway                            = { key = "edge" }
    certificate                        = { key = "tls" }
    http2_enabled                      = true
    request_client_certificate_enabled = false
    tls10_enabled                      = false
    tls11_enabled                      = false
  }
}
