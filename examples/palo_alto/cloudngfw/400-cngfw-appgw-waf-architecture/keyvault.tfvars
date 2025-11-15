# Key Vault for SSL Certificates
# Following Azure Best Practices:
# - Soft delete enabled for protection against accidental deletion
# - Purge protection enabled for production workloads
# - RBAC authorization for modern access control
# - Network ACLs with service endpoints

keyvaults = {
  appgw_certificates = {
    name               = "appgw-certs"
    resource_group_key = "networking_rg"
    sku_name           = "standard"

    # Enable soft delete and purge protection for production
    soft_delete_retention_days = 90
    purge_protection_enabled   = true

    # Use RBAC instead of access policies (modern approach)
    enable_rbac_authorization = true

    # Network security
    network = {
      bypass         = "AzureServices"
      default_action = "Allow" # For demo; use "Deny" with service endpoints in production
    }

    tags = {
      purpose     = "ssl-certificates"
      managed_by  = "terraform"
      environment = "production"
    }
  }
}

# SSL Certificate Configuration
# Following repository pattern: generate certificate in Key Vault
# Pattern from: examples/networking/app_gateway/209-agw-with-keyvault-ssl-policy/certificates.tfvars
keyvault_certificates = {
  app_example_com = {
    keyvault_key = "appgw_certificates"

    # Certificate name (alphanumeric and dashes only)
    name = "app-example-com-cert"

    # Ensure the logged-in operator has RBAC access before Terraform provisions the certificate
    ensure_logged_in_access = true

    # Certificate properties
    subject            = "CN=app.example.com"
    validity_in_months = 12

    subject_alternative_names = {
      dns_names = [
        "app.example.com"
      ]
    }

    tags = {
      type        = "SelfSigned"
      application = "demo-app"
    }

    # Self-signed certificate (for demo purposes)
    issuer_parameters = "Self"

    exportable = true
    key_size   = 4096
    key_type   = "RSA"
    reuse_key  = true

    # Auto-renew before expiry
    action_type = "AutoRenew"

    # Renew when 10% of lifetime remains
    lifetime_percentage = 10

    content_type = "application/x-pkcs12"

    key_usage = [
      "cRLSign",
      "dataEncipherment",
      "digitalSignature",
      "keyAgreement",
      "keyCertSign",
      "keyEncipherment",
    ]
  }
}
