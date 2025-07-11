global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  inherit_tags = true
  tags = {
    env     = "demo"
    project = "static-web-app-custom-domain"
  }
}

resource_groups = {
  rg1 = {
    name   = "staticsite"
    region = "region1"
    tags = {
      purpose = "static-web-app-custom-domain-demo"
    }
  }
}

static_sites = {
  s1 = {
    name               = "staticsite"
    resource_group_key = "rg1"
    region             = "region1"

    # SKU Configuration for azurerm_static_web_app
    sku_tier = "Standard" # Free or Standard (custom domains require Standard)
    sku_size = "Standard" # Free or Standard

    # Optional settings
    configuration_file_changes_enabled = true
    preview_environments_enabled       = true
    public_network_access_enabled      = true

    # Custom domains configuration
    custom_domains = {
      # Root domain with TXT token validation
      # Requirements:
      # 1. Create a TXT record: _dnsauth.mystaticsite.com
      # 2. Set the value to the validation_token from terraform output
      # 3. Also needs an ALIAS/A record pointing to the static web app's default hostname
      txt_domain = {
        domain_name     = "mystaticsite.com"
        validation_type = "dns-txt-token"
      }

      # Subdomain with CNAME delegation validation
      # Requirements:
      # 1. Create a CNAME record: subdomain.mystaticsite.com
      # 2. Point it to the static web app's default hostname
      # Note: CNAME cannot be placed at the root domain level
      cname_subdomain = {
        domain_name     = "subdomain.mystaticsite.com"
        validation_type = "cname-delegation"
      }

      # WWW subdomain with CNAME delegation validation
      # Requirements:
      # 1. Create a CNAME record: www.mystaticsite.com
      # 2. Point it to the static web app's default hostname
      www_subdomain = {
        domain_name     = "www.mystaticsite.com"
        validation_type = "cname-delegation"
      }
    }

    # Optional app settings
    app_settings = {
      "CUSTOM_SETTING" = "value"
      "ENVIRONMENT"    = "demo"
    }

    tags = {
      tier    = "standard"
      purpose = "custom-domain-demo"
    }
  }
}
