global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}
resource_groups = {
  rg1 = {
    name   = "databricks-re1"
    region = "region1"
  }
}
data_factory = {
  df1 = {
    name = "example"
    resource_group = {
      key = "rg1"
      #lz_key = ""
      #name = ""
    }
  }
}
data_factory_pipeline = {
  dfp1 = {
    name                           = "example"
    moniter_metrics_after_duration = "00:05:00"
    resource_group = {
      key = "rg1"
      #lz_key = ""
      #name = ""
    }
    data_factory = {
      key = "df1"
      #lz_key = ""
      #name = ""
    }
  }
  current = {
    name                           = "current-metrics"
    resource_group                 = { key = "rg1" }
    data_factory                   = { key = "df1" }
    monitor_metrics_after_duration = "00:10:00"
    moniter_metrics_after_duration = "00:01:00"
  }
}