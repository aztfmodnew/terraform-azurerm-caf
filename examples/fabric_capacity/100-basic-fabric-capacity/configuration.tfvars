global_settings = {
  default_region = "region1"
  inherit_tags   = true
  regions = {
    region1 = "westeurope"
  }
  prefixes = ["caf"]
}

resource_groups = {
  analytics_rg = {
    name   = "fabric-analytics"
    region = "region1"
    tags = {
      workload = "analytics"
    }
  }
}

fabric_capacities = {
  analytics_capacity = {
    region             = "region1"
    resource_group_key = "analytics_rg"

    sku = {
      name = "F16"
      tier = "Fabric"
    }

    administration_members = [
      "dataops_lead@contoso.com",
      "00000000-0000-0000-0000-000000000001"
    ]

    tags = {
      environment = "test"
      owner       = "analytics-team"
    }
  }
}
