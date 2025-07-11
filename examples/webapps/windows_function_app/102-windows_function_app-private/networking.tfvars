vnets = {
  spoke = {
    resource_group_key = "spoke"
    region             = "region1"
    vnet = {
      name          = "spoke-vnet"
      address_space = ["10.1.0.0/22"]
    }
    specialsubnets = {}
    subnets = {
      app = {
        name = "snet-functions"
        cidr = ["10.1.0.0/26"]
        delegation = {
          name               = "Microsoft.Web.serverFarms"
          service_delegation = "Microsoft.Web/serverFarms"
          actions            = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
      private_endpoints = {
        name = "snet-privateendpoints"
        cidr = ["10.1.1.0/26"]
        # No delegation needed for private endpoints
      }
      bastion = {
        name = "snet-bastion"
        cidr = ["10.1.2.0/26"]
        # For management access if needed
      }
    }
  }
}

network_security_group_definition = {
  # NSG for function app subnet
  functions_nsg = {
    nsg = [
      {
        name                       = "AllowHTTPS"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTP"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
  
  # NSG for private endpoints subnet
  private_endpoints_nsg = {
    nsg = [
      {
        name                       = "AllowVnetInbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
      }
    ]
  }
}

network_security_groups = {
  functions_nsg = {
    resource_group_key     = "spoke"
    name                   = "nsg-functions"
    nsg_definition_key     = "functions_nsg"
  }
  
  private_endpoints_nsg = {
    resource_group_key     = "spoke"
    name                   = "nsg-privateendpoints"
    nsg_definition_key     = "private_endpoints_nsg"
  }
}

# Associate NSGs with subnets
network_security_group_associations = {
  functions_subnet = {
    name                   = "nsg-assoc-functions"
    vnet_key              = "spoke"
    subnet_key            = "app"
    networksecuritygroup_key = "functions_nsg"
  }
  
  private_endpoints_subnet = {
    name                   = "nsg-assoc-privateendpoints"
    vnet_key              = "spoke"
    subnet_key            = "private_endpoints"
    networksecuritygroup_key = "private_endpoints_nsg"
  }
}
