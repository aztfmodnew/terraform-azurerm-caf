# SSL Certificate Configuration for Azure Bot Application Gateway
keyvault_certificates = {
  "secure-bot-endpoint.example.com" = {
    keyvault_key = "bot_certificates_kv"

    # Certificate name (may only contain alphanumeric characters and dashes)
    name = "secure-bot-endpoint-example-com"

    # Certificate subject and validity
    subject            = "CN=secure-bot-endpoint.example.com"
    validity_in_months = 12

    # Subject Alternative Names for the certificate
    subject_alternative_names = {
      # DNS names that this certificate will be valid for
      dns_names = [
        "secure-bot-endpoint.example.com",
        "*.secure-bot-endpoint.example.com"
      ]
    }

    tags = {
      type         = "SelfSigned"
      architecture = "secure-bot"
      environment  = "production"
      cost_center  = "it-security"
      service      = "bot-ssl"
      purpose      = "application-gateway-ssl"
      example      = "azure-bot-waf-private-endpoint"
      landingzone  = "examples"
    }

    # Self-signed certificate issuer (for demo purposes)
    # For production, use a trusted CA like "Unknown" for Let's Encrypt or commercial CAs
    issuer_parameters = "Self"

    # Certificate settings
    exportable = true
    key_size   = 4096 # Strong key size for security
    key_type   = "RSA"
    reuse_key  = true

    # Auto-renewal settings
    action_type        = "AutoRenew"
    days_before_expiry = 30 # Renew 30 days before expiration

    # Certificate format
    content_type = "application/x-pkcs12" # PFX format for Application Gateway

    # Key usage settings appropriate for SSL/TLS
    key_usage = [
      "cRLSign",
      "dataEncipherment",
      "digitalSignature",
      "keyAgreement",
      "keyCertSign",
      "keyEncipherment"
    ]
  }
}
