global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  webapprg = {
    name   = "webapp-diagnostics"
    region = "region1"
  }
}
