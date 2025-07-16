global_settings = {
  default_region = "region1"
  environment    = "dev"
  prefix         = "caf"
  suffix         = "001"
  
  regions = {
    region1 = "australiaeast"
  }
  
  inherit_tags = true
  
  # Hybrid naming configuration - using azurecaf (default)
  naming = {
    use_azurecaf      = true
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

# https://docs.microsoft.com/en-us/azure/storage/
# Example: Basic storage account with hybrid naming (azurecaf method)
# Expected name: caf-st-sa1dev-dev-001
storage_accounts = {
  sa1 = {
    name = "sa1dev"
    # This option is to enable remote RG reference
    # resource_group = {
    #   lz_key = ""
    #   key    = ""
    # }

    resource_group_key = "test"
    # Account types are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2
    account_kind = "BlobStorage"
    # Account Tier options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_tier = "Standard"
    #  Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS
    account_replication_type = "LRS" # https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy
    tags = {
      environment = "dev"
      team        = "IT"
      ##
    }
    containers = {
      dev = {
        name = "random"
      }
    }

    enable_system_msi = true
    customer_managed_key = {
      keyvault_key = "stg_byok"

      # Reference to the var.keyvault_keys
      keyvault_key_key = "byok"
    }
  }
  sa2 = {
    name               = "sa2dev"
    resource_group_key = "test"
    # Account types are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2
    account_kind = "BlockBlobStorage"
    # Account Tier options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_tier = "Premium"
    #  Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS
    account_replication_type = "ZRS" # https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy
    tags = {
      environment = "dev"
      team        = "IT"
      ##
    }
    containers = {
      dev = {
        name = "random"
      }
    }

    enable_system_msi = true
    customer_managed_key = {
      keyvault_key = "stg_byok"

      # Reference to the var.keyvault_keys
      keyvault_key_key = "byok"
    }
  }
}

diagnostic_storage_accounts = {
  dsa1 = {
    name               = "dsa1dev"
    resource_group_key = "test"
    # Account types are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2
    account_kind = "BlobStorage"
    # Account Tier options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_tier = "Standard"
    #  Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS
    account_replication_type = "LRS" # https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy
    tags = {
      environment = "dev"
      team        = "IT"
      ##
    }

    enable_system_msi = true
    customer_managed_key = {
      keyvault_key = "stg_byok"

      # Reference to the var.keyvault_keys
      keyvault_key_key = "diabyok"
    }
  }
}
