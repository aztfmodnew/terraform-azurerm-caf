storage_accounts = {
  sa1 = {
    name                     = "sa1dev"
    resource_group_key       = "webapp_storage"
    account_kind             = "BlobStorage"
    account_tier             = "Standard"
    account_replication_type = "LRS"

    containers = {
      sc1 = {
        name = "sc1"
      }
    }
  }
  sa2 = {
    name                     = "sa2dev"
    resource_group_key       = "webapp_storage"
    account_kind             = "FileStorage"
    account_tier             = "Premium"
    account_replication_type = "LRS"
    min_tls_version          = "TLS1_2"
    large_file_share_enabled = true

    file_shares = {
      fs1 = {
        name  = "fs1"
        quota = 50
      }
    }
  }
}
