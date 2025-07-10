global_settings = {
  default_region = "region1"
  regions = {
    region1 = "eastus2"
  }
}

resource_groups = {
  webapp_appgw = {
    name   = "webapp-appgw"
    region = "region1"
  }
}
