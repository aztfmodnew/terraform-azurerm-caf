global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
  inherit_tags = true
  tags = {
    env = "production"
    project = "windows-functions-private"
  }
}

resource_groups = {
  funapp = {
    name   = "winfunapp-private"
    region = "region1"
  }
  spoke = {
    name   = "spoke-network"
    region = "region1"
  }
}

# Windows service plan for Function App
service_plans = {
  asp1 = {
    resource_group_key = "funapp"
    name               = "win-funapp-plan"
    os_type            = "Windows"
    sku_name           = "P1v3"  # Premium for VNet integration
    
    tags = {
      project = "Windows Functions"
      tier    = "Premium"
    }
  }
}

storage_accounts = {
  sa1 = {
    name               = "winfunappprivsa"
    resource_group_key = "funapp"
    region             = "region1"

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    
    # Disable public access for security
    public_network_access_enabled = false
    
    # Enable hierarchical namespace for better performance
    is_hns_enabled = false

    containers = {
      functions = {
        name = "azure-webjobs-hosts"
      }
      deployments = {
        name = "deployments"
      }
    }

    tags = {
      purpose = "function-app-storage"
    }
  }
}

# Windows Function App configuration
windows_function_apps = {
  function_app1 = {
    name                    = "win-function-app-private"
    resource_group_key      = "funapp"
    service_plan_key        = "asp1"
    storage_account_key     = "sa1"
    
    # Enable VNet integration
    virtual_network_subnet = {
      vnet_key   = "spoke"
      subnet_key = "app"
    }
    
    # Function app configuration
    site_config = {
      always_on                         = true
      use_32_bit_worker                = false
      ftps_state                       = "Disabled"
      http2_enabled                    = true
      websockets_enabled               = false
      minimum_tls_version              = "1.2"
      scm_minimum_tls_version          = "1.2"
      
      # Enable private endpoints
      public_network_access_enabled    = false
      
      # Application insights
      application_insights_key         = "appinsights1"
      application_insights_connection_string_name = "APPLICATIONINSIGHTS_CONNECTION_STRING"
      
      # IP restrictions for additional security
      ip_restriction = [
        {
          name                = "AllowVNet"
          priority            = 100
          action              = "Allow"
          # Note: virtual_network_subnet_id should be a string, not an object
          # For now, removing this to avoid the error
          # virtual_network_subnet_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/spoke-vnet/subnets/snet-functions"
        }
      ]
      
      # CORS settings
      cors = {
        allowed_origins = [
          "https://portal.azure.com",
          "https://ms.portal.azure.com"
        ]
        support_credentials = false
      }
    }
    
    # Application settings
    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME"                 = "dotnet"
      "FUNCTIONS_EXTENSION_VERSION"              = "~4"
      "WEBSITE_RUN_FROM_PACKAGE"                 = "1"
      "WEBSITE_ENABLE_SYNC_UPDATE_SITE"          = "true"
      "WEBSITE_VNET_ROUTE_ALL"                   = "1"
      "WEBSITE_DNS_SERVER"                       = "168.63.129.16"
      "WEBSITE_CONTENTOVERVNET"                  = "1"
      "SCM_DO_BUILD_DURING_DEPLOYMENT"           = "false"
      "ENABLE_ORYX_BUILD"                        = "false"
    }
    
    # Identity for secure access to other Azure services
    identity = {
      type = "SystemAssigned"
    }
    
    tags = {
      project = "Windows Functions"
      tier    = "Premium"
      environment = "Private"
    }
  }
}

# Application Insights
azurerm_application_insights = {
  appinsights1 = {
    name                 = "appinsights-winfunapp"
    resource_group_key   = "funapp"
    application_type     = "web"
    retention_in_days    = 90
    
    # Disable public network access
    internet_ingestion_enabled = false
    internet_query_enabled     = false
    
    tags = {
      project = "Windows Functions"
      purpose = "Monitoring"
    }
  }
}

vnets = {
  spoke = {
    resource_group_key = "spoke"
    region             = "region1"
    vnet = {
      name          = "spoke-vnet"
      address_space = ["10.1.0.0/22"]
    }
    specialsubnets = {}
    subnets = {
      app = {
        name = "snet-functions"
        cidr = ["10.1.0.0/26"]
        nsg_key = "functions_nsg"
        delegation = {
          name               = "Microsoft.Web.serverFarms"
          service_delegation = "Microsoft.Web/serverFarms"
          actions            = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
      private_endpoints = {
        name = "snet-privateendpoints"
        cidr = ["10.1.1.0/26"]
        nsg_key = "private_endpoints_nsg"
        # No delegation needed for private endpoints
      }
      bastion = {
        name = "snet-bastion"
        cidr = ["10.1.2.0/26"]
        nsg_key = "bastion_nsg"
        # For management access if needed
      }
    }
  }
}

# Private DNS zones for private endpoints
private_dns = {
  "privatelink.blob.core.windows.net" = {
    name               = "privatelink.blob.core.windows.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-blob-link"
        vnet_key = "spoke"
      }
    }
  }
  
  "privatelink.file.core.windows.net" = {
    name               = "privatelink.file.core.windows.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-file-link"
        vnet_key = "spoke"
      }
    }
  }
  
  "privatelink.azurewebsites.net" = {
    name               = "privatelink.azurewebsites.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-webapp-link"
        vnet_key = "spoke"
      }
    }
  }
}

# Network Security Group Definitions
network_security_group_definition = {
  functions_nsg = {
    nsg = [
      {
        name                       = "AllowHTTPS"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTP"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowVNetInbound"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
      }
    ]
  }
  
  private_endpoints_nsg = {
    nsg = [
      {
        name                       = "AllowVNetInbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
      }
    ]
  }
  
  bastion_nsg = {
    nsg = [
      {
        name                       = "AllowHTTPS"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowSSH"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

# Private Endpoints configuration using CAF pattern
private_endpoints = {
  spoke = {
    vnet_key    = "spoke"
    subnet_keys = ["private_endpoints"]
    
    # Private endpoint for storage account
    storage_accounts = {
      sa1 = {
        name = "pe-storage-sa1"
        private_service_connection = {
          name              = "psc-storage-sa1"
          subresource_names = ["blob", "file"]
        }
        
        private_dns = {
          zone_group_name = "storage-zone-group"
          keys = ["privatelink.blob.core.windows.net", "privatelink.file.core.windows.net"]
        }
      }
    }
    
    # Private endpoint for Windows Function App
    windows_function_apps = {
      function_app1 = {
        name = "pe-function-app1"
        private_service_connection = {
          name              = "psc-function-app1"
          subresource_names = ["sites"]
        }
        
        private_dns = {
          zone_group_name = "function-app-zone-group"
          keys = ["privatelink.azurewebsites.net"]
        }
      }
    }
  }
}
