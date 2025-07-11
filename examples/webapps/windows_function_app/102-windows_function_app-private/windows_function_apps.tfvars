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