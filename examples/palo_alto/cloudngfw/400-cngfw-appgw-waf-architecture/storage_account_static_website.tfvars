# Storage account hosting the static website behind the WAF/NGFW chain plus a private endpoint on the backend subnet

storage_accounts = {
  demo_static_website = {
    name                      = "webdemo"
    resource_group_key        = "networking_rg"
    location                  = "eastus"
    account_tier              = "Standard"
    account_replication_type  = "LRS"
    enable_https_traffic_only = true
    enable_static_website     = true
    static_website = {
      index_document     = "index.html"
      error_404_document = "404.html"
    }
    tags = {
      environment = "production"
      purpose     = "static-website"
    }
    # Private Endpoint en la subred de backend
    private_endpoints = {
      backend_pe = {
        name       = "backend-pe"
        vnet_key   = "hub_vnet"
        subnet_key = "backend_subnet"
        private_service_connection = {
          name                 = "backend-pe-conn"
          is_manual_connection = false
          subresource_names    = ["blob"]
        }
        private_dns = {
          zone_group_name = "backend-pe"
          keys            = ["blob_dns"]
        }
      }
    }
  }
}

# Web content is uploaded automatically through storage_account_blobs.tfvars; manual uploads are optional for customization.
