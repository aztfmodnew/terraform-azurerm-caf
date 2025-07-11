global_settings = {
  default_region = "region1"
  regions = {
    region1 = "southeastasia"
  }
}

resource_groups = {
  webapp_storage = {
    name   = "webapp-storage"
    region = "region1"
  }
}
