locals {
  # Expected Variable: connection_strings = {
  #   app_conn_string = {
  #     name = "app_db"
  #     type = "SQLAzure"
  #     value = "@Microsoft.KeyVault(VaultName=keyvault_name;SecretName=secret_name)"
  #   }
  # }
  connection_strings = {
    for key, value in try(var.settings.connection_strings, {}) : key => {
      name  = value.name
      type  = value.type
      value = value.value
    }
  }
}
