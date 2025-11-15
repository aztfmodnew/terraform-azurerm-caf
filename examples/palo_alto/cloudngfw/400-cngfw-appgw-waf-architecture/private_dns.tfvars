# Private DNS Configuration for Storage Account Private Endpoint
# Required for blob storage private endpoint resolution

private_dns = {
  blob_dns = {
    name               = "privatelink.blob.core.windows.net"
    resource_group_key = "networking_rg"

    tags = {
      resource = "private dns"
      service  = "storage"
      purpose  = "blob-private-endpoint"
    }

    vnet_links = {
      hub_vnet_link = {
        name     = "hub-blob-dns-link"
        vnet_key = "hub_vnet"
        tags = {
          networking = "dns-link"
        }
      }
    }
  }
}
