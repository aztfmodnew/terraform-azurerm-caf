global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  test = {
    name = "route-server-test"
  }
}

vnets = {
  hub_vnet = {
    resource_group_key = "test"
    vnet = {
      name          = "hub-vnet"
      address_space = ["10.0.0.0/16"]
    }
    specialsubnets = {
      RouteServerSubnet = {
        name = "RouteServerSubnet" # must be named RouteServerSubnet
        cidr = ["10.0.1.0/24"]
      }
    }
    subnets = {}
  }
}

public_ip_addresses = {
  rs_pip = {
    name               = "rs-pip"
    resource_group_key = "test"
    sku                = "Standard" # must be 'Standard' SKU
    allocation_method  = "Static"
    ip_version         = "IPv4"
  }
}

route_servers = {
  rs1 = {
    name               = "core-rs"
    resource_group_key = "test"
    vnet_key           = "hub_vnet"
    subnet_key         = "RouteServerSubnet"
    public_ip_key      = "rs_pip"
    sku                = "Standard"

    tags = {
      purpose = "route-server-example"
    }
  }
}
