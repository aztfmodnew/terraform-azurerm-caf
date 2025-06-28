keyvaults = {
  cdn_kv = {
    name               = "cdn-frontdoor-kv"
    resource_group_key = "cdn_rg"
    sku_name           = "standard"
    soft_delete_enabled = true
    purge_protection_enabled  = false
    
    # Enable RBAC authorization instead of access policies
    enable_rbac_authorization = true
    
    


    tags = {
      purpose = "cdn-frontdoor"
    }
  }
}

# Remove keyvault_access_policies - replaced by role_mapping below

keyvault_certificate_requests = {
  cdn_certificate = {
    name         = "cdn-certificate"
    keyvault_key = "cdn_kv"
    
    certificate_policy = {
      issuer_key_or_name  = "self"
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
