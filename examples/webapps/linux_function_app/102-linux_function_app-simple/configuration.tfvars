global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  rg1 = {
    name   = "funapp-private"
    region = "region1"
  }
}


storage_accounts = {
  sa1 = {
    name                     = "functionsapptestsa"
    resource_group_key       = "rg1"
    region                   = "region1"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

service_plans = {
  asp1 = {
    name               = "azure-functions-test-service-plan"
    resource_group_key = "rg1"
    region             = "region1"
    os_type            = "Linux"
    sku_name           = "Y1"
  }
}
