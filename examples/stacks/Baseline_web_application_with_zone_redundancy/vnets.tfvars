vnets = {
  vnet1 = {
    resource_group_key = "rg1"
    vnet = {
      name          = "webapp"
      address_space = ["10.0.0.0/16"]
    }
    specialsubnets = {}
    subnets = {
      appgw = {
        name    = "appgw"
        cidr    = ["10.0.1.0/24"]
        nsg_key = "appgw"
      }
      app_service_integration = {
        name = "app_service_integration"
        cidr = ["10.0.2.0/24"]
        delegation = {
          name               = "serverFarms"
          service_delegation = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
        nsg_key = "app_service_integration"
      }
      private_endpoints = {
        name                              = "private_endpoints"
        cidr                              = ["10.0.3.0/24"]
        private_endpoint_network_policies = "Enabled"
        nsg_key                           = "private_endpoints"
      }
    }
  }
}