vnets = {
  vnet_aadds_re1 = {
    resource_group_key = "rg"
    region             = "region1"
    vnet = {
      name          = "aadds"
      address_space = ["10.10.0.0/16"]
      dns_servers = [
        "10.10.1.4",
        "10.10.1.5",
        "10.20.1.4",
        "10.20.1.5"
      ]
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" # must be named GatewaySubnet
        cidr = ["10.10.255.0/27"]
      }
    }
    subnets = {
      aadds = {
        name    = "aadds"
        cidr    = ["10.10.1.0/24"]
        nsg_key = "aadds_re1"
      }
      vms = {
        name    = "vms"
        cidr    = ["10.10.2.0/24"]
        nsg_key = "vms"
      }
    }
  }
  vnet_aadds_re2 = {
    resource_group_key = "rg_remote"
    region             = "region2"
    vnet = {
      name          = "remote"
      address_space = ["10.20.0.0/16"]
      dns_servers = [
        "10.10.1.4",
        "10.10.1.5",
        "10.20.1.4",
        "10.20.1.5"
      ]
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" # must be named GatewaySubnet
        cidr = ["10.20.255.0/27"]
      }
    }
    subnets = {
      aadds = {
        name    = "aadds"
        cidr    = ["10.20.1.0/24"]
        nsg_key = "aadds_re2"
      }
      vms = {
        name    = "vms"
        cidr    = ["10.20.2.0/24"]
        nsg_key = "vms"
      }
    }
  }
}