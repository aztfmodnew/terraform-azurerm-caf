public_ip_addresses = {
  vngw_pip = {
    name               = "vngw_pip1"
    resource_group_key = "rg"
    sku                = "Standard"
    allocation_method  = "Static"
    # allocation method needs to be Static
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
  }

  vngw_pip2 = {
    name               = "vngw_pip2"
    resource_group_key = "rg"
    sku                = "Standard"
    allocation_method  = "Static"
    # allocation method needs to be Static
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
  }
  vngw2_pip = {
    name               = "vngw2_pip1"
    resource_group_key = "rg_remote"
    sku                = "Standard"
    allocation_method  = "Static"
    # allocation method needs to be Static
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
  }
  vngw2_pip2 = {
    name               = "vngw2_pip2"
    resource_group_key = "rg_remote"
    sku                = "Standard"
    allocation_method  = "Static"
    # allocation method needs to be Static
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
  }
}

virtual_network_gateways = {
  gateway1 = {
    name                       = "mygateway"
    resource_group_key         = "rg"
    type                       = "Vpn"
    sku                        = "VpnGw2AZ"
    private_ip_address_enabled = true
    # enable active_active only with VPN Type
    active_active = true
    # enable_bpg defaults to false. If set, true, input the necessary parameters as well. VPN Type only
    enable_bgp = true
    vpn_type   = "RouteBased"
    # multiple IP configs are needed for active_active state. VPN Type only.
    # do not create multiple IP configuration for ExpressRoute type.
    ip_configuration = {
      ipconfig1 = {
        ipconfig_name         = "gatewayIp1"
        public_ip_address_key = "vngw_pip"
        #lz_key                        = "examples"
        #lz_key optional, only needed if the vnet_key is inside another landing zone
        vnet_key                      = "vnet_aadds_re1"
        private_ip_address_allocation = "Dynamic"
      }
      ipconfig2 = {
        ipconfig_name         = "gatewayIp2"
        public_ip_address_key = "vngw_pip2"
        #lz_key                        = "examples"
        #lz_key optional, only needed if the vnet_key is inside another landing zone
        vnet_key                      = "vnet_aadds_re1"
        private_ip_address_allocation = "Dynamic"
      }
    }
    bgp_settings = {
      bpgsettings1 = {
        asn             = 65512
        peering_address = "10.0.0.5"
        peer_weight     = 0
      }
    }
  }
  gateway2 = {
    name                       = "mygateway2"
    resource_group_key         = "rg_remote"
    type                       = "Vpn"
    sku                        = "VpnGw2AZ"
    private_ip_address_enabled = true
    # enable active_active only with VPN Type
    active_active = true
    # enable_bpg defaults to false. If set, true, input the necessary parameters as well. VPN Type only
    enable_bgp = true
    vpn_type   = "RouteBased"
    # multiple IP configs are needed for active_active state. VPN Type only.
    # do not create multiple IP configuration for ExpressRoute type.
    ip_configuration = {
      ipconfig1 = {
        ipconfig_name         = "gatewayIp1"
        public_ip_address_key = "vngw2_pip"
        #lz_key                        = "examples"
        #lz_key optional, only needed if the vnet_key is inside another landing zone
        vnet_key                      = "vnet_aadds_re2"
        private_ip_address_allocation = "Dynamic"
      }
      ipconfig2 = {
        ipconfig_name         = "gatewayIp2"
        public_ip_address_key = "vngw2_pip2"
        #lz_key                        = "examples"
        #lz_key optional, only needed if the vnet_key is inside another landing zone
        vnet_key                      = "vnet_aadds_re2"
        private_ip_address_allocation = "Dynamic"
      }
    }
    bgp_settings = {
      bpgsettings1 = {
        asn             = 65512
        peering_address = "10.0.0.5"
        peer_weight     = 0
      }
    }
  }
}

virtual_network_gateway_connections = {
  connection1 = {
    name               = "connection-vnet1-to-vnet2"
    resource_group_key = "rg"
    # type can be Vnet, IPsec, or ExpressRoute
    type                             = "Vnet2Vnet"
    region                           = "region1"
    virtual_network_gateway_key      = "gateway1"
    shared_key                       = "P@ssw0rd1234!"
    peer_virtual_network_gateway_key = "gateway2"
    # peer_virtual_network_gateway_key is required for VVnet2Vnet type
  }
  connection2 = {
    name               = "connection-vnet2-to-vnet1"
    resource_group_key = "rg_remote"
    # type can be Vnet, IPsec, or ExpressRoute
    type                             = "Vnet2Vnet"
    region                           = "region2"
    virtual_network_gateway_key      = "gateway2"
    shared_key                       = "P@ssw0rd1234!"
    peer_virtual_network_gateway_key = "gateway1"
    # peer_virtual_network_gateway_key is required for VVnet2Vnet type
  }
}
