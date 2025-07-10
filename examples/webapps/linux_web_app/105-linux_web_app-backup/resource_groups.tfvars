global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  webapp_backup = {
    name   = "webapp-backup"
    region = "region1"
  }
}
