vnets = {
  vnet_region1 = {
    resource_group_key = "test_re1"
    vnet = {
      name          = "virtual_machines"
      address_space = ["10.100.100.0/24"]
    }
    specialsubnets = {}
    subnets = {
      example = {
        name = "examples"
        cidr = ["10.100.100.0/29"]
      }
    }
  }
  vnet_hub_region1 = {
    resource_group_key = "test_re1"
    region             = "region1"
    vnet = {
      name          = "hub-re1"
      address_space = ["100.64.100.0/22"]
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" #Must be called GateWaySubnet in order to host a Virtual Network Gateway
        cidr = ["100.64.100.0/27"]
      }
      AzureFirewallSubnet = {
        name = "AzureFirewallSubnet" #Must be called AzureFirewallSubnet
        cidr = ["100.64.101.0/26"]
      }
    }
    subnets = {
      AzureBastionSubnet = {
        name    = "AzureBastionSubnet" #Must be called AzureBastionSubnet
        cidr    = ["100.64.101.64/26"]
        nsg_key = "azure_bastion_nsg"
      }
      jumpbox = {
        name    = "jumpbox"
        cidr    = ["100.64.102.0/27"]
        nsg_key = "jumpbox"
      }
      private_endpoints = {
        name                              = "private_endpoints"
        cidr                              = ["100.64.103.128/25"]
        private_endpoint_network_policies = "Enabled"
      }
    }
  }
  vnet_workload_region1 = {
    resource_group_key = "test_re1"
    region             = "region1"
    vnet = {
      name           = "workload-re1"
      address_space  = ["100.64.104.0/24"]
      specialsubnets = {}
      subnets = {
        example = {
          name = "examples"
          cidr = ["10.64.104.0/29"]
        }
      }
    }

  }
}