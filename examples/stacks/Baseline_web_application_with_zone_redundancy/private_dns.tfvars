## DNS configuration

private_dns = {
  azurewebsites_dns = {
    name               = "privatelink.azurewebsites.net"
    resource_group_key = "rg1"

    tags = {
      resource = "private dns"
    }

    vnet_links = {
      vnlk1 = {
        name = "auto-vnet-link"
        # lz_key   = ""
        vnet_key = "vnet1"
        tags = {
          net_team = "noc1"
        }
      }
    }
  }
  database_dns = {
    name               = "privatelink.database.windows.net"
    resource_group_key = "rg1"

    vnet_links = {
      vnlk2 = {
        name = "auto-vnet-link"
        #lz_key   = "launchpad"
        vnet_key = "vnet1"
        tags = {
          net_team = "noc1"
        }
      }
    }
  }
}