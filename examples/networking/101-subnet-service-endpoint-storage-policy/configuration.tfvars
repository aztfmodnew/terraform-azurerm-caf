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
  example     = "subnet-service-endpoint-storage-policy"
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

# Virtual Network Configuration
vnets = {
  vnet1 = {
    resource_group_key = "networking_rg"
    vnet = {
      name          = "subnet-policy-vnet"
      address_space = ["10.100.0.0/16"]
    }
  }
}

# Subnet Configuration with Service Endpoints
virtual_subnets = {
  storage_subnet = {
    name = "storage-subnet"
    cidr = ["10.100.1.0/24"]
    nsg_key = "empty_nsg"
    service_endpoints = ["Microsoft.Storage"]
    vnet = {
      key = "vnet1"
    }
  }
}

# Network Security Group Definition
network_security_group_definition = {
  empty_nsg = {
    nsg = []
  }
}

# Storage Accounts for the policy
storage_accounts = {
  allowed_storage = {
    name                     = "allowedstorage001"
    resource_group_key       = "storage_rg"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    
    network_rules = {
      default_action = "Deny"
      virtual_network_subnet_ids = [
        # This will be populated by the subnet reference
      ]
    }

    tags = {
      purpose = "allowed-storage"
      tier    = "standard"
    }
  }
  
  restricted_storage = {
    name                     = "restrictedstorage001"
    resource_group_key       = "storage_rg"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    
    network_rules = {
      default_action = "Deny"
    }

    tags = {
      purpose = "restricted-storage"
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
          # Specific storage account resource ID
          "/subscriptions/db600528-5207-4293-91a2-a8144db2dbdf/resourceGroups/caf-rg-storage-rg/providers/Microsoft.Storage/storageAccounts/cafstallowedstorage001"
        ]
      }
    }

    tags = {
      purpose = "storage-access-control"
      type    = "service-endpoint-policy"
    }
  }
}

# Example of subnet policy association (this would be done in subnet configuration)
# Note: The actual association would be done in the subnet configuration using:
# service_endpoint_policy_ids = [policy_id]
