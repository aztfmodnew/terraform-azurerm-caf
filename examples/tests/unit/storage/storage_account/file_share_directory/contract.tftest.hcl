mock_provider "azurerm" {}

run "legacy_share_url_alias" {
  command = plan
  module {
    source = "../modules/storage_account/file_share_directory"
  }
  variables {
    storage_share_id = "https://legacy.file.core.windows.net/documents"
    settings         = { name = "archive" }
  }
  assert {
    condition     = azurerm_storage_share_directory.share_directory.storage_share_url == "https://legacy.file.core.windows.net/documents"
    error_message = "Legacy callers supplying a share URL through storage_share_id must remain supported."
  }
}
run "current_share_url_precedence" {
  command = plan
  module {
    source = "../modules/storage_account/file_share_directory"
  }
  variables {
    storage_share_url = "https://current.file.core.windows.net/documents"
    storage_share_id  = "https://legacy.file.core.windows.net/documents"
    settings          = { name = "archive" }
  }
  assert {
    condition     = azurerm_storage_share_directory.share_directory.storage_share_url == "https://current.file.core.windows.net/documents"
    error_message = "The current storage_share_url input must take precedence over its legacy alias."
  }
}
