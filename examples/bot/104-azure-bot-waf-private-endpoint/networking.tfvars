# Virtual Network Configuration
vnets = {
  secure_vnet = {
    resource_group_key = "networking_rg"
    vnet = {
      name          = "secure-bot-vnet"
      address_space = ["10.100.0.0/16"]
    }
  }
}

# Subnet Configuration
virtual_subnets = {
  # Application Gateway Subnet
  appgw_subnet = {
    name    = "appgw-subnet"
    cidr    = ["10.100.1.0/24"]
    nsg_key = "appgw_nsg"
    vnet = {
      key = "secure_vnet"
    }
  },

  # Private Endpoint Subnet
  private_endpoints = {
    name                              = "private-endpoint-subnet"
    cidr                              = ["10.100.2.0/24"]
    nsg_key                           = "pe_nsg"
    private_endpoint_network_policies = "Enabled"
    vnet = {
      key = "secure_vnet"
    }
  },

  # Bot Application Subnet (for any backend services)
  bot_subnet = {
    name    = "bot-app-subnet"
    cidr    = ["10.100.3.0/24"]
    nsg_key = "bot_nsg"
    vnet = {
      key = "secure_vnet"
    }
    service_endpoints = ["Microsoft.Web", "Microsoft.Storage"]
  }
}

# Route Tables for Custom Routing
route_tables = {
  # Route table for Application Gateway subnet
  appgw_rt = {
    resource_group_key = "networking_rg"
    name               = "secure-bot-appgw-rt"

    routes = {
      # Route to internet for outbound connections
      internet_route = {
        name           = "internet-route"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
    }

    tags = {
      networking = "routing"
      service    = "application-gateway"
    }
  },

  # Route table for bot application subnet
  bot_rt = {
    resource_group_key = "networking_rg"
    name               = "secure-bot-app-rt"

    routes = {
      # Route traffic to Application Gateway subnet
      appgw_route = {
        name           = "to-appgw-subnet"
        address_prefix = "10.100.1.0/24"
        next_hop_type  = "VnetLocal"
      },
      # Route to private endpoint subnet
      pe_route = {
        name           = "to-pe-subnet"
        address_prefix = "10.100.2.0/24"
        next_hop_type  = "VnetLocal"
      }
    }

    tags = {
      networking = "routing"
      service    = "bot-application"
    }
  }
}

# Virtual Network Peering (if connecting to other VNets)
# virtual_network_peerings = {
#   # Peering to hub network (example)
#   hub_peering = {
#     name                         = "secure-bot-to-hub-peering"
#     virtual_network_key          = "secure_vnet"
#     remote_virtual_network_id    = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/hub-vnet"
#     allow_virtual_network_access = true
#     allow_forwarded_traffic      = true
#     allow_gateway_transit        = false
#     use_remote_gateways         = false
#     
#     tags = {
#       networking = "peering"
#       purpose    = "hub-connectivity"
#     }
#   }
# }

# Network Watchers for monitoring (commented out - using existing network watcher)
# network_watchers = {
#   bot_network_watcher = {
#     resource_group_key = "networking_rg"
#     name               = "secure-bot-network-watcher"
#     location           = "westeurope"
#
#     tags = {
#       monitoring = "network"
#       service    = "bot-infrastructure"
#     }
#   }
# }

# Public IP for Application Gateway
public_ip_addresses = {
  appgw_pip = {
    name               = "secure-bot-appgw-pip"
    resource_group_key = "networking_rg"
    sku                = "Standard"
    allocation_method  = "Static"
    zones              = ["1", "2", "3"]

    tags = {
      networking = "public ip"
      service    = "application gateway"
      purpose    = "bot-waf-protection"
    }
  }
}
