mssql_servers = {
  sql_rg1 = {
    name                = "sql-rg1"
    region              = "region1"
    resource_group_key  = "nsp_re1"
    administrator_login = "sqladmin"
    keyvault_key        = "sql_rg1"
    identity = {
      type = "SystemAssigned"
    }
  }
}