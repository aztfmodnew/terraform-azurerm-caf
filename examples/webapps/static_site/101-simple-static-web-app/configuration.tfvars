global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  inherit_tags = true
  tags = {
    env = "demo"
    project = "static-web-app"
  }
}

resource_groups = {
  rg1 = {
    name   = "staticsite"
    region = "region1"
    tags = {
      purpose = "static-web-app-demo"
    }
  }
}

static_sites = {
  s1 = {
    name               = "staticsite"
    resource_group_key = "rg1"
    region             = "region1"

    # SKU Configuration for azurerm_static_web_app
    sku_tier = "Standard"  # Free or Standard
    sku_size = "Standard"  # Free or Standard
    
    # Optional settings
    configuration_file_changes_enabled = true
    preview_environments_enabled       = true
    public_network_access_enabled     = true
    
    # Optional app settings
    app_settings = {
      "CUSTOM_SETTING" = "value"
      "ENVIRONMENT"    = "demo"
    }
    
    # Optional repository configuration (if using GitHub integration)
    # repository_url    = "https://github.com/user/repo"
    # repository_branch = "main"
    # repository_token  = "github_token" # Store securely
    
    tags = {
      tier = "standard"
      purpose = "demo"
    }
  }
}
