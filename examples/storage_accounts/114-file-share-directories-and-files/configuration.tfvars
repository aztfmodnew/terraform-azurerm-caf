global_settings = {
  default_region = "region1"
  regions        = { region1 = "australiaeast" }
  random_length  = 5
}

resource_groups = {
  files = { name = "file-services" }
}

storage_accounts = {
  files = {
    name                     = "filemigration"
    resource_group           = { key = "files" }
    account_tier             = "Standard"
    account_replication_type = "LRS"
    file_shares = {
      documents = {
        name  = "documents"
        quota = 10
        directories = {
          archive = { name = "archive" }
        }
        files = {
          root = {
            name   = "root.txt"
            source = "./storage_accounts/104-file-share-with-backup/fileA"
          }
          archived = {
            name   = "archived.txt"
            path   = "archive"
            source = "./storage_accounts/104-file-share-with-backup/fileB"
          }
        }
      }
    }
  }
}
