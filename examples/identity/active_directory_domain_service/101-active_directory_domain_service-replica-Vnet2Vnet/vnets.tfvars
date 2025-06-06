vnets = {
  vnet_aadds_re1 = {
    resource_group_key = "rg"
    region             = "region1"
    vnet = {
      name          = "vnet-aadds"
      address_space = ["10.10.0.0/16"]
      dns_servers   = []
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" # must be named GatewaySubnet
        cidr = ["10.10.255.0/27"]
      }
    }
    subnets = {
      aadds = {
        name    = "snet-aadds"
        cidr    = ["10.10.1.0/24"]
        nsg_key = "aadds"
      }
      vms = {
        name    = "snet-vms"
        cidr    = ["10.10.2.0/24"]
        nsg_key = "vms"
      }     
    }
  }
  vnet_aadds_re2 = {
    resource_group_key = "rg_remote"
    region             = "region2"
    vnet = {
      name          = "vnet-remote"
      address_space = ["10.20.0.0/16"]
      dns_servers   = []
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" # must be named GatewaySubnet
        cidr = ["10.20.255.0/27"]
      }
    }
    subnets = {
      default = {
        name = "default"
        cidr = ["10.20.1.0/24"]
      }
      GatewaySubnet = {
        name = "GatewaySubnet"
        cidr = ["10.20.255.0/27"]
      }
    }
  }
}
