# Storage Account con Static Website y Private Endpoint en la subred de backend

storage_accounts = {
  demo_static_website = {
    name                      = "webdemo"
    resource_group_key        = "networking_rg"
    location                  = "eastus2"
    account_tier              = "Standard"
    account_replication_type  = "LRS"
    enable_https_traffic_only = true
    enable_static_website     = true
    static_website = {
      index_document     = "index.html"
      error_404_document = "404.html"
    }
    tags = {
      environment = "demo"
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

# Puedes subir el contenido web a mano tras el despliegue usando Azure Portal o azcopy.
