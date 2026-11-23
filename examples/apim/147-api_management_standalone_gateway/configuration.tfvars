global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "workspace-gateway", region = "primary" }
}
vnets = {
  hub = {
    resource_group_key = "gateway"
    vnet = {
      name = "workspace-gateway", address_space = ["10.40.0.0/16"]
    }
    subnets = {
      workspace_gateway = {
        name = "workspace-gateway", cidr = ["10.40.0.0/24"]
        delegation = {
          name               = "workspace-gateway"
          service_delegation = "Microsoft.Web/serverFarms"
          actions            = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }
}

api_management_standalone_gateway = {
  workspace = {
    name                 = "workspace-gateway"
    resource_group       = { key = "gateway" }
    subnet               = { vnet_key = "hub", key = "workspace_gateway" }
    virtual_network_type = "External"
    sku                  = { name = "WorkspaceGatewayPremium", capacity = 1 }
    tags                 = { environment = "example" }
  }
}
