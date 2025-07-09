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
    project     = "frontdoor-static-website"
  }
}

resource_groups = {
  static_website = {
    name     = "frontdoor-static-website"
    location = "eastus"
    tags = {
      purpose = "static website hosting"
    }
  }
}
