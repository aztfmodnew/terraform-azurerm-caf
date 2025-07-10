resource_groups = {
  dmz-rt-dev-network = {
    # Existing resource group name
    name  = "fibc-rg-mi-networking-re1"
    reuse = true
  }
}

storage_accounts = {
  sa1 = {
    name                     = "functionsapptestsa"
    resource_group_key       = "dmz-rt-dev-network"
    region                   = "region1"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

service_plans = {
  asp1 = {
    name               = "azure-functions-test-service-plan"
    resource_group_key = "dmz-rt-dev-network"
    region             = "region1"
    os_type            = "Linux"
    sku_name           = "Y1"
  }
}

function_apps = {
  faaps1 = {
    name                 = "test-azure-functions"
    resource_group_key   = "dmz-rt-dev-network"
    region               = "region1"
    service_plan_key = "asp1"
    storage_account_key  = "sa1"
    settings = {
      os_type = "linux"
      version = "~3"
    }
  }
}