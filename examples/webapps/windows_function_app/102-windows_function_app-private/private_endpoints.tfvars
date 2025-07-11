# Private DNS zones for private endpoints
private_dns = {
  privatelink.blob.core.windows.net = {
    name               = "privatelink.blob.core.windows.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-blob-link"
        vnet_key = "spoke"
      }
    }
  }
  
  privatelink.file.core.windows.net = {
    name               = "privatelink.file.core.windows.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-file-link"
        vnet_key = "spoke"
      }
    }
  }
  
  privatelink.azurewebsites.net = {
    name               = "privatelink.azurewebsites.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-webapp-link"
        vnet_key = "spoke"
      }
    }
  }
}

# Private endpoints for storage account
private_endpoints = {
  storage_blob = {
    name                          = "pe-storage-blob"
    resource_group_key            = "funapp"
    vnet_key                      = "spoke"
    subnet_key                    = "private_endpoints"
    
    # Link to storage account
    resource = {
      lz_key = null
      key    = "sa1"
    }
    
    private_service_connection = {
      name                           = "psc-storage-blob"
      is_manual_connection           = false
      subresource_names              = ["blob"]
    }
    
    private_dns_zone_group = {
      name = "pdns-storage-blob"
      private_dns_zone_ids = [
        # Reference to private DNS zone
      ]
    }
  }
  
  storage_file = {
    name                          = "pe-storage-file"
    resource_group_key            = "funapp"
    vnet_key                      = "spoke"
    subnet_key                    = "private_endpoints"
    
    # Link to storage account
    resource = {
      lz_key = null
      key    = "sa1"
    }
    
    private_service_connection = {
      name                           = "psc-storage-file"
      is_manual_connection           = false
      subresource_names              = ["file"]
    }
    
    private_dns_zone_group = {
      name = "pdns-storage-file"
      private_dns_zone_ids = [
        # Reference to private DNS zone
      ]
    }
  }
}
