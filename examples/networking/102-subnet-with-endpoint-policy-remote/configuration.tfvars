global_settings = {
  default_region = "region1"
  inherit_tags   = true
  regions = {
    region1 = "westeurope"
  }
  prefixes = ["caf"]
  use_slug = true
}

tags = {
  example     = "subnet-endpoint-policy-remote"
  landingzone = "examples"
}

resource_groups = {
  networking_rg = {
    name   = "subnet-endpoint-policy-rg"
    region = "region1"
  }
  storage_rg = {
    name   = "storage-rg"
    region = "region1"
  }
}

# Virtual Network
vnets = {
  main_vnet = {
    resource_group_key = "networking_rg"
    vnet = {
      name          = "main-vnet"
      address_space = ["10.0.0.0/16"]
    }
  }
}

# Storage Accounts
storage_accounts = {
  allowed_storage = {
    name                     = "allowedstorage002"
    resource_group_key       = "storage_rg"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    
    tags = {
      purpose = "allowed-storage"
      tier    = "standard"
    }
  }
}

# Subnet Service Endpoint Storage Policy
subnet_service_endpoint_storage_policies = {
  storage_policy = {
    name               = "storage-access-policy"
    resource_group_key = "networking_rg"
    
    definitions = {
      allowed_storage_def = {
        name        = "AllowedStorageDefinition"
        description = "Policy definition allowing access to specific storage accounts"
        service     = "Microsoft.Storage"
        service_resources = [
          "/subscriptions/12345678-1234-1234-1234-123456789123/resourceGroups/caf-rg-storage-rg/providers/Microsoft.Storage/storageAccounts/cafstallowedstorage002"
          


        ]
      }
    }

    tags = {
      purpose = "storage-access-control"
      type    = "service-endpoint-policy"
    }
  }
}

# Virtual Subnets with Service Endpoint Policy using remote_objects
virtual_subnets = {
  storage_subnet = {
    name = "storage-subnet"
    cidr = ["10.0.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
    
    # Using remote_objects to reference the policy
    service_endpoint_policies = ["storage_policy"]
    
    vnet = {
      key = "main_vnet"
    }
  },
  
  # Example with direct IDs (alternative approach)
  direct_subnet = {
    name = "direct-subnet"
    cidr = ["10.0.2.0/24"]
    service_endpoints = ["Microsoft.Storage"]
    
    # Using direct policy IDs (would be populated after policy creation)
    # service_endpoint_policy_ids = [
    #   "/subscriptions/.../providers/Microsoft.Network/serviceEndpointPolicies/storage-policy"
    # ]
    
    vnet = {
      key = "main_vnet"
    }
  }
}
