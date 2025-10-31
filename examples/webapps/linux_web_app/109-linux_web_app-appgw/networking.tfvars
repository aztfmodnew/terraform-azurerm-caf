vnets = {
  webapp_appgw = {
    resource_group_key = "webapp_appgw"
    region             = "region1"
    vnet = {
      name          = "webapp-appgw"
      address_space = ["10.1.0.0/24"]
    }
    specialsubnets = {}
    subnets = {
      appgw = {
        name              = "appgw"
        cidr              = ["10.1.0.0/28"]
        service_endpoints = ["Microsoft.Web"]
      }
      webapp = {
        name = "webapp"
        cidr = ["10.1.0.16/28"]
        delegation = {
          name               = "serverFarms"
          service_delegation = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }
    }
  }
}

public_ip_addresses = {
  pip_appgw = {
    name               = "appgw"
    resource_group_key = "webapp_appgw"
    sku                = "Standard"
    allocation_method  = "Static"
  }
}
