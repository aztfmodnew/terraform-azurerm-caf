global_settings = {
  default_region = "region1"
  environment    = "examples"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  sql_region1 = {
    name   = "sql-rg1"
    region = "region1"
  }
}

mssql_servers = {
  sql_rg1 = {
    name                = "sql-rg1"
    region              = "region1"
    resource_group_key  = "sql_region1"
    administrator_login = "sqladmin"
    keyvault_key        = "sql_rg1"
    security_alert_policy = {
      storage_account           = { key = "auditing" }
      email_subscription_admins = true
      retention_days            = 7
    }
    extended_auditing_policy = {
      storage_account   = { key = "auditing" }
      retention_in_days = 7
    }
  }
}

keyvaults = {
  sql_rg1 = {
    name               = "sqlrg1"
    resource_group_key = "sql_region1"
    sku_name           = "standard"

    creation_policies = {
      logged_in_user = {
        secret_permissions = ["Set", "Get", "List", "Delete", "Purge"]
      }
    }
  }
}

storage_accounts = {
  auditing = {
    name                     = "sqlauditing"
    resource_group_key       = "sql_region1"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

mssql_databases = {
  application = {
    name               = "application"
    mssql_server_key   = "sql_rg1"
    resource_group_key = "sql_region1"
    sku_name           = "S0"
    threat_detection_policy = {
      state                = "Enabled"
      email_account_admins = true
      storage_account      = { key = "auditing" }
      retention_days       = 7
    }
    extended_auditing_policy = {
      storage_account   = { key = "auditing" }
      retention_in_days = 7
    }
  }
}