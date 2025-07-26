# Storage Account with Local Module Naming
# This example demonstrates the local module naming method
# Expected name: caf-st-advanced-dev-aue-001

global_settings = {
  default_region = "region1"
  environment    = "dev"
  prefix         = "caf"
  suffix         = "001"

  regions = {
    region1 = "australiaeast"
  }

  inherit_tags = true

  # Hybrid naming configuration - using local module
  naming = {
    use_azurecaf     = false
    use_local_module = true
    component_order  = ["prefix", "abbreviation", "name", "environment", "region", "suffix"]
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
  advanced_storage = {
    name                     = "advanced"
    resource_group_key       = "test"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    min_tls_version          = "TLS1_2"
    allow_blob_public_access = false
    is_hns_enabled           = false
    sftp_enabled             = false

    # Override global settings for this resource
    environment = "dev"
    region      = "australiaeast"
    instance    = "001"

    tags = {
      environment = "dev"
      team        = "IT"
      purpose     = "local-module-naming-demo"
    }

    containers = {
      dev = {
        name = "development"
      }
      staging = {
        name = "staging"
      }
    }

    enable_system_msi = true

    blob_properties = {
      cors_rule = {
        allowed_headers    = ["x-ms-meta-data*", "x-ms-meta-target*"]
        allowed_methods    = ["POST", "GET"]
        allowed_origins    = ["http://localhost:3000"]
        exposed_headers    = ["x-ms-meta-*"]
        max_age_in_seconds = "200"
      }
    }

    delete_retention_policy = {
      days = "7"
    }
  }
}
