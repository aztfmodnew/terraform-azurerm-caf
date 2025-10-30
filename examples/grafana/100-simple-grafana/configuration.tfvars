global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  grafana_rg = {
    name = "grafana-test-1"
  }
}


grafana = {
  grafana1 = {
    name                          = "grafana-test-1"
    grafana_major_version         = 11
    sku                           = "Standard"
    api_key_enabled               = true
    public_network_access_enabled = true

    resource_group = {
      # accepts either id or key to get resource group id
      # id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourceGroup1"
      # lz_key = "examples"
      key = "grafana_rg"
    }

    identity = {
      type = "SystemAssigned"
    }

    tags = {
      environment = "dev"
      purpose     = "example"
    }
  }
}

