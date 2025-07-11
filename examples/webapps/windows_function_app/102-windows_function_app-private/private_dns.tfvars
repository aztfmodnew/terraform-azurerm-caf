# Private DNS zones for private endpoints
private_dns = {
  "privatelink.blob.core.windows.net" = {
    name               = "privatelink.blob.core.windows.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-blob-link"
        vnet_key = "spoke"
      }
    }
  }
  
  "privatelink.file.core.windows.net" = {
    name               = "privatelink.file.core.windows.net"
    resource_group_key = "spoke"
    
    vnet_links = {
      spoke = {
        name     = "spoke-file-link"
        vnet_key = "spoke"
      }
    }
  }
  
  "privatelink.azurewebsites.net" = {
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