global_settings = {
  default_region = "region1"
  environment    = "dev"
  prefix         = "caf"
  suffix         = "acl"

  regions = {
    region1 = "uksouth"
  }

  inherit_tags = true

  # Hybrid naming configuration - using azurecaf (default)
  naming = {
    use_azurecaf     = true
    use_local_module = false
  }
}

resource_groups = {
  test = {
    name = "test"
  }
}

# https://docs.microsoft.com/en-us/azure/storage/
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
    account_kind = "StorageV2"
    # Account Tier options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid.
    account_tier = "Standard"
    #  Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS
    account_replication_type = "LRS" # https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy

    file_shares = {
      share1 = {
        name  = "share1"
        quota = 50

        acl = {
          id = "GhostedRecall"

          access_policy = {
            permissions = "r"
          }
        }
      }
    }
  }
}
