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
          nsg_key            = "functions_nsg"
        }
      }
      private_endpoints = {
        name    = "snet-privateendpoints"
        cidr    = ["10.1.1.0/26"]
        nsg_key = "private_endpoints_nsg"
        # No delegation needed for private endpoints
      }
      bastion = {
        name    = "snet-bastion"
        cidr    = ["10.1.2.0/26"]
        nsg_key = "bastion_nsg"
        # For management access if needed
      }
    }
  }
}
