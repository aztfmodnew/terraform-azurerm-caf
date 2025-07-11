# Private Endpoints configuration using CAF pattern
private_endpoints = {
  spoke = {
    vnet_key    = "spoke"
    subnet_keys = ["private_endpoints"]
    
    # Private endpoint for storage account
    storage_accounts = {
      sa1 = {
        name = "pe-storage-sa1"
        private_service_connection = {
          name              = "psc-storage-sa1"
          subresource_names = ["blob", "file"]
        }
        
        private_dns = {
          zone_group_name = "storage-zone-group"
          keys = ["privatelink.blob.core.windows.net", "privatelink.file.core.windows.net"]
        }
      }
    }
    
    # Private endpoint for Windows Function App
    windows_function_apps = {
      function_app1 = {
        name = "pe-function-app1"
        private_service_connection = {
          name              = "psc-function-app1"
          subresource_names = ["sites"]
        }
        
        private_dns = {
          zone_group_name = "function-app-zone-group"
          keys = ["privatelink.azurewebsites.net"]
        }
      }
    }
  }
}