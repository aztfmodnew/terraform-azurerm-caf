global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  rg1 = {
    name = "logic-app-mi"
  }
}

storage_accounts = {
  sa1 = {
    name                     = "lastd"
    resource_group_key       = "rg1"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

service_plans = {
  asp1 = {
    name               = "logicapp-plan1"
    resource_group_key = "rg1"
    os_type            = "Windows"
    sku_name           = "WS1"
  }
}

managed_identities = {
  logicapp_msi = {
    name               = "logicapp-mi"
    resource_group_key = "rg1"
  }
}

logic_app_standard = {
  las1 = {
    name                = "logicapp1"
    resource_group_key  = "rg1"
    service_plan_key    = "asp1"
    storage_account_key = "sa1"
    version             = "~4"

    vnet_integration = {
      vnet_key   = "vnet1"
      subnet_key = "snet_la"
    }

    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["logicapp_msi"]
    }
  }
}

vnets = {
  vnet1 = {
    resource_group_key = "rg1"
    vnet = {
      name          = "la-vnet"
      address_space = ["10.0.0.0/24"]
    }
    specialsubnets = {}
    subnets = {
      snet_la = {
        name = "la-integration"
        cidr = ["10.0.0.0/27"]
        delegation = {
          name               = "functions"
          service_delegation = "Microsoft.Web/serverFarms"
          actions            = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }
}
