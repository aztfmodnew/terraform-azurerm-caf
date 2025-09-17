# Private DNS Configuration
private_dns = {
  bot_dns = {
    name               = "privatelink.directline.botframework.com"
    resource_group_key = "networking_rg"

    tags = {
      resource = "private dns"
      service  = "bot"
      purpose  = "private-endpoint-resolution"
    }

    vnet_links = {
      secure_vnet_link = {
        name     = "secure-bot-vnet-link"
        vnet_key = "secure_vnet"
        tags = {
          networking = "dns-link"
          purpose    = "private-endpoint"
        }
      }
    }
  }
}
