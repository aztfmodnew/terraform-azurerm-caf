# Storage Account with Passthrough Naming
# This example demonstrates the passthrough naming method
# Expected name: mystorageaccount2024 (exact name as specified)

global_settings = {
  default_region = "region1"
  environment    = "dev"
  prefix         = "caf"
  suffix         = "001"
  
  regions = {
    region1 = "australiaeast"
  }
  
  inherit_tags = true
  
  # Hybrid naming configuration - using passthrough (exact names)
  passthrough = true
  
  naming = {
    use_azurecaf      = false
    use_local_module  = false
  }
}

provider_azurerm_features_keyvault = {
  // set to true to cleanup the CI
  purge_soft_delete_on_destroy = false
}

resource_groups = {
  test = {
    name = "test"
  }
}

storage_accounts = {
  exact_name_storage = {
    name                     = "mystorageaccount2024"  # This exact name will be used
    resource_group_key       = "test"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    min_tls_version          = "TLS1_2"
    allow_blob_public_access = false
    is_hns_enabled           = false
    sftp_enabled             = false
    
    tags = {
      environment = "dev"
      team        = "IT"
      purpose     = "passthrough-naming-demo"
      note        = "Using exact name without any CAF transformations"
    }
    
    containers = {
      uploads = {
        name = "uploads"
      }
      backups = {
        name = "backups"
      }
    }
    
    enable_system_msi = true
    
    blob_properties = {
      cors_rule = {
        allowed_headers    = ["*"]
        allowed_methods    = ["GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS"]
        allowed_origins    = ["*"]
        exposed_headers    = ["*"]
        max_age_in_seconds = "86400"
      }
    }
    
    delete_retention_policy = {
      days = "30"
    }
  }
}
