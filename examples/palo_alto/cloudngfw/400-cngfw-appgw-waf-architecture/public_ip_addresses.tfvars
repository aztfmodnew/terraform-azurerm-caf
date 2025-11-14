# Public IP Addresses
public_ip_addresses = {
  appgw_pip = {
    name               = "appgw-cngfw-example"
    resource_group_key = "networking_rg"
    sku                = "Standard"
    allocation_method  = "Static"
    zones              = ["1", "2", "3"] # Zone-redundant for high availability
    tags = {
      environment = "production"
      purpose     = "Application Gateway Public IP"
    }
  }

  ngfw_management_pip = {
    name               = "cngfw-management"
    resource_group_key = "networking_rg"
    sku                = "Standard"
    allocation_method  = "Static"
    zones              = ["1", "2", "3"]
    tags = {
      environment = "production"
      purpose     = "Cloud NGFW Management"
    }
  }

  ngfw_dataplane_pip = {
    name               = "cngfw-dataplane"
    resource_group_key = "networking_rg"
    sku                = "Standard"
    allocation_method  = "Static"
    zones              = ["1", "2", "3"]
    tags = {
      environment = "production"
      purpose     = "Cloud NGFW Data Plane"
    }
  }

  bastion_pip = {
    name               = "bastion-management"
    resource_group_key = "networking_rg"
    sku                = "Standard"
    allocation_method  = "Static"
    zones              = ["1", "2", "3"]
    tags = {
      environment = "production"
      purpose     = "Azure Bastion"
    }
  }
}
