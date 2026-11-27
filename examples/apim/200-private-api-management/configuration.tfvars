global_settings = {
  default_region = "region1"
  environment    = "test"
  random_length  = 4
  regions = {
    region1 = "westeurope"
  }
}

resource_groups = {
  apim = {
    name   = "private-apim"
    region = "region1"
  }
}

vnets = {
  apim = {
    resource_group_key = "apim"
    vnet = {
      name          = "apim-private"
      address_space = ["10.20.0.0/24"]
    }
    subnets = {
      private_endpoints = {
        name                              = "private-endpoints"
        cidr                              = ["10.20.0.0/27"]
        private_endpoint_network_policies = "Disabled"
      }
    }
    specialsubnets = {}
  }
}

private_dns = {
  apim = {
    name               = "privatelink.azure-api.net"
    resource_group_key = "apim"
  }
}

private_dns_vnet_links = {
  apim = {
    vnet_key = "apim"
    private_dns_zones = {
      apim = {
        name = "apim-private-link"
        key  = "apim"
      }
    }
  }
}

api_management = {
  private_ai_gateway = {
    name               = "private-ai-gateway"
    resource_group_key = "apim"
    publisher_name     = "Private AI Gateway"
    publisher_email    = "owner@example.com"
    sku_name           = "Standard_1"
    # Keep public access enabled for the initial apply so Azure can create the
    # private endpoint. Disable it in a second apply after the endpoint exists.
    public_network_access_enabled = true

    private_endpoints = {
      gateway = {
        name               = "apim-gateway"
        resource_group_key = "apim"
        vnet_key           = "apim"
        subnet_key         = "private_endpoints"
        private_service_connection = {
          name                 = "apim-gateway"
          is_manual_connection = false
          subresource_names    = ["Gateway"]
        }
        private_dns = {
          zone_group_name = "apim-gateway"
          keys            = ["apim"]
        }
      }
    }
  }
}
