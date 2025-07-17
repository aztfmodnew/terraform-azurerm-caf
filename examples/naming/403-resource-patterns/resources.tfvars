# Resource Pattern Specialization - Different Patterns for Different Resource Types
# Each Azure resource type uses an optimized naming pattern

# Storage Accounts: No separators due to Azure naming constraints
storage_accounts = {
  data_lake = {
    name               = "datalake"
    resource_group_key = "storage"
    account_tier       = "Standard"
    account_replication_type = "LRS"
    instance           = "001"
    # Result: azuredatalakeprod001 (no separators)
  }
  
  backup_store = {
    name               = "backup"
    resource_group_key = "storage"
    account_tier       = "Standard"
    account_replication_type = "GRS"
    instance           = "002"
    # Result: azurebackupprod002 (no separators)
  }
}

# Key Vaults: Hyphens with region for global uniqueness
key_vaults = {
  app_secrets = {
    name                = "appsecrets"
    resource_group_key  = "security"
    # Result: azure-appsecrets-prod-westeurope (with region)
  }
  
  cert_store = {
    name                = "certificates"
    resource_group_key  = "security"
    # Result: azure-certificates-prod-westeurope (with region)
  }
}

# Container App Environments: Underscores with full component set
container_app_environments = {
  web_platform = {
    name                = "webapp"
    resource_group_key  = "compute"
    instance            = "001"
    # Result: azure_cae_webapp_prod_001_v1 (underscores, full set)
  }
  
  api_platform = {
    name                = "api"
    resource_group_key  = "compute"
    instance            = "002"
    # Result: azure_cae_api_prod_002_v1 (underscores, full set)
  }
}

# Virtual Networks: Hyphens with region and instance
virtual_networks = {
  main_network = {
    name                = "main"
    resource_group_key  = "networking"
    address_space       = ["10.0.0.0/16"]
    instance            = "001"
    # Result: azure-vnet-main-prod-westeurope-001 (with region)
  }
  
  dmz_network = {
    name                = "dmz"
    resource_group_key  = "networking"
    address_space       = ["10.1.0.0/16"]
    instance            = "001"
    # Result: azure-vnet-dmz-prod-westeurope-001 (with region)
  }
}

# Linux Web Apps: Hyphens without region for simplicity
linux_web_apps = {
  frontend_app = {
    name                = "frontend"
    resource_group_key  = "webapps"
    service_plan_key    = "main_plan"
    # Result: azure-app-frontend-prod-v1 (no region)
  }
  
  backend_api = {
    name                = "backend"
    resource_group_key  = "webapps"
    service_plan_key    = "main_plan"
    # Result: azure-app-backend-prod-v1 (no region)
  }
}

# SQL Databases: Hyphens with instance for scaling
mssql_databases = {
  user_data = {
    name               = "userdata"
    resource_group_key = "databases"
    server_key         = "main_server"
    instance           = "001"
    # Result: azure-userdata-prod-001-v1 (with instance)
  }
  
  analytics_data = {
    name               = "analytics"
    resource_group_key = "databases"
    server_key         = "main_server"
    instance           = "002"
    # Result: azure-analytics-prod-002-v1 (with instance)
  }
}

# Supporting resources
resource_groups = {
  storage = {
    name = "storage-rg"
  }
  security = {
    name = "security-rg"
  }
  compute = {
    name = "compute-rg"
  }
  networking = {
    name = "networking-rg"
  }
  webapps = {
    name = "webapps-rg"
  }
  databases = {
    name = "databases-rg"
  }
}

service_plans = {
  main_plan = {
    name                = "main"
    resource_group_key  = "webapps"
    os_type             = "Linux"
    sku_name            = "P1v2"
  }
}

mssql_servers = {
  main_server = {
    name                = "main"
    resource_group_key  = "databases"
    version             = "12.0"
    administrator_login = "sqladmin"
  }
}
