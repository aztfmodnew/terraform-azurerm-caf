global_settings = {
  random_length  = "4"
  default_region = "region1"
  regions = {
    region1 = "eastus"
    region2 = "westus2"
  }
  inherit_tags = true
  tags = {
    environment = "demo"
    project     = "frontdoor-static-website-with-waf"
  }
}

resource_groups = {
  static_website = {
    name     = "frontdoor-static-website-with-waf"
    location = "eastus"
    tags = {
      purpose = "static website hosting with WAF"
    }
  }
}

landingzone = {
  backend_type        = "azurerm"
  global_settings_key = "launchpad"
  level               = "level4"
  key                 = "examples"
  tfstates = {
    launchpad = {
      level   = "lower"
      tfstate = "caf_launchpad.tfstate"
    }
  }
}
