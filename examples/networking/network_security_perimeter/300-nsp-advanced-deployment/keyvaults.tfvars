keyvaults = {
  stg_byok = {
    name                     = "vmsecrets"
    resource_group_key       = "nsp_re1"
    sku_name                 = "standard"
    purge_protection_enabled = true
  }
  sql_rg1 = {
    name               = "sqlrg1"
    resource_group_key = "nsp_re1"
    sku_name           = "standard"
    creation_policies = {
      logged_in_user = {
        secret_permissions = ["Set", "Get", "List", "Delete", "Purge"]
      }
    }
  }
}
