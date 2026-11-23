global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "certificate-workspace", region = "region1" }
}
managed_identities = {
  certificates = {
    name               = "workspace-certificates"
    resource_group_key = "gateway"
  }
}
api_management = {
  gateway = {
    name            = "certificate-workspace"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Premium_1"
    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["certificates"]
    }
  }
}
api_management_workspace = {
  team = {
    name           = "payments"
    display_name   = "Payments"
    api_management = { key = "gateway" }
  }
}
keyvaults = {
  certificates = {
    name               = "workspace-certs"
    resource_group_key = "gateway"
    sku_name           = "standard"
    creation_policies = {
      logged_in_user = {
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
keyvault_certificate_requests = {
  backend = {
    name         = "backend-client"
    keyvault_key = "certificates"
    certificate_policy = {
      issuer_key_or_name  = "Self"
      exportable          = true
      key_size            = 2048
      key_type            = "RSA"
      reuse_key           = false
      renewal_action      = "AutoRenew"
      lifetime_percentage = 80
      content_type        = "application/x-pkcs12"
      x509_certificate_properties = {
        subject            = "CN=backend.example.com"
        validity_in_months = 12
        key_usage          = ["digitalSignature", "keyEncipherment"]
        subject_alternative_names = {
          dns_names = ["backend.example.com"]
          emails    = []
          upns      = []
        }
      }
    }
  }
}
api_management_workspace_certificate = {
  backend = {
    name                     = "backend-client"
    api_management_workspace = { key = "team" }
    key_vault_secret         = { certificate_request_key = "backend" }
    managed_identity         = { key = "certificates" }
  }
}
