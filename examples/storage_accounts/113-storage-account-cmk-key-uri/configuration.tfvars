global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}

resource_groups = {
  storage = { name = "cmk-key-uri" }
}

storage_accounts = {
  encrypted = {
    name                     = "cmkuri"
    resource_group           = { key = "storage" }
    account_tier             = "Standard"
    account_replication_type = "LRS"
    min_tls_version          = "TLS1_2"
    identity                 = { type = "SystemAssigned" }

    customer_managed_key = {
      # Replace with an existing key URI; omit its version for automatic version updates.
      key_vault_key_id = "https://replace-with-your-vault.vault.azure.net/keys/storage-encryption"
    }
  }
}
