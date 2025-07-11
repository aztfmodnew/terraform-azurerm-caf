windows_function_apps = {
  winf1 = {
    name               = "winfunapp-private"
    resource_group_key = "funapp"
    region             = "region1"

    service_plan_key    = "asp1"
    storage_account_key = "sa1"

    # VNet integration for outbound connectivity
    settings = {
      vnet_key   = "spoke"
      subnet_key = "app"
      enabled    = true
      
      # Disable public network access
      public_network_access_enabled = false
      
      # Use storage account over VNet
      storage_uses_managed_identity = true
    }
    
    functions_extension_version = "~4"
    
    site_config = {
      # Always on is required for Premium plans
      always_on = true
      
      # Use 64-bit worker process for better performance
      use_32_bit_worker = false
      
      # Enable HTTP/2
      http2_enabled = true
      
      # Minimum TLS version
      minimum_tls_version = "1.2"
      
      # Disable FTP for security
      ftps_state = "Disabled"
      
      # Route all traffic through VNet
      vnet_route_all_enabled = true
      
      application_stack = {
        dotnet_version              = "v6.0"
        use_dotnet_isolated_runtime = false
      }
      
      # CORS configuration if needed
      cors = {
        allowed_origins = [
          "https://portal.azure.com"
        ]
        support_credentials = false
      }
      
      # IP restrictions - only allow traffic from VNet
      ip_restriction = [
        {
          name     = "AllowVNet"
          priority = 100
          action   = "Allow"
          virtual_network_subnet_id = "subnet_id_placeholder"  # Will be resolved by module
        }
      ]
      
      # SCM site restrictions
      scm_use_main_ip_restriction = true
    }
    
    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME"                = "dotnet"
      "FUNCTIONS_EXTENSION_VERSION"             = "~4"
      "AzureWebJobsDisableHomepage"             = "true"
      
      # Storage account settings for private connectivity
      "AzureWebJobsStorage__accountName"        = "winfunappprivsa"
      "AzureWebJobsStorage__credential"         = "managedidentity"
      "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = ""  # Will use managed identity
      "WEBSITE_CONTENTSHARE"                    = "winfunapp-private"
      
      # Networking settings
      "WEBSITE_VNET_ROUTE_ALL"                  = "1"
      "WEBSITE_DNS_SERVER"                      = "168.63.129.16"
      
      # Security settings
      "WEBSITE_HTTPS_ONLY"                      = "1"
      "WEBSITE_MINIMUM_TLS_VERSION"             = "1.2"
    }
    
    # Managed identity for secure access to storage
    identity = {
      type = "SystemAssigned"
    }
    
    # Private endpoint for the function app
    private_endpoints = {
      functionapp = {
        name                          = "pe-functionapp"
        resource_group_key            = "funapp"
        vnet_key                      = "spoke"
        subnet_key                    = "private_endpoints"
        
        private_service_connection = {
          name                           = "psc-functionapp"
          is_manual_connection           = false
          subresource_names              = ["sites"]
        }
        
        private_dns_zone_group = {
          name = "pdns-functionapp"
          private_dns_zone_keys = ["privatelink.azurewebsites.net"]
        }
      }
    }
    
    # Enhanced security and monitoring
    tags = {
      application = "secure-functions"
      environment = "production"
      security    = "private-endpoint"
      compliance  = "high"
    }
  }
}
