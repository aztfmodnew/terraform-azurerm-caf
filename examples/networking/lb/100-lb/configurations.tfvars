global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
  random_length = 5
}

resource_groups = {
  rg1 = {
    name = "example-lb"
  }
}


public_ip_addresses = {
  lb_pip = {
    name                    = "lb_pip1"
    resource_group_key      = "rg1"
    sku                     = "Standard"
    allocation_method       = "Static"
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"
  }
  integrated_pip = {
    name               = "integrated"
    resource_group_key = "rg1"
    sku                = "Standard"
    allocation_method  = "Static"
  }
}

# Public Load Balancer will be created. For Internal/Private Load Balancer config, please refer 102-internal-load-balancer example.


vnets = {
  vnet1 = {
    resource_group_key = "rg1"
    vnet = {
      name          = "vnet1"
      address_space = ["10.100.100.0/24"]
    }
    specialsubnets = {}
    subnets = {
      subnet1 = {
        name = "subnet1"
        cidr = ["10.100.100.0/29"]
      }
    }

  }
}

lb = {
  lb1 = {
    name   = "TestLoadBalancer"
    region = "region1"
    resource_group = {
      key = "rg1"
    }
    frontend_ip_configuration = {
      name = "PublicIPAddress"
      public_ip_address = {
        key = "lb_pip"
      }
    }
    sku = "Standard"
  }
}


lb_backend_address_pool = {
  lbap1 = {
    loadbalancer = {
      key = "lb1"
    }
    name = "BackEndAddressPool"
  }
}

lb_backend_address_pool_address = {
  lbbapa1 = {
    name = "example"
    backend_address_pool = {
      key = "lbap1"
    }
    virtual_network = {
      key = "vnet1"
    }
    ip_address = "10.100.100.4"
  }
}

lb_nat_pool = {
  lbnp1 = {
    resource_group = {
      key = "rg1"
    }
    loadbalancer = {
      key = "lb1"
    }
    name                           = "SampleApplicationPool"
    protocol                       = "Tcp"
    frontend_port_start            = 80
    frontend_port_end              = 81
    backend_port                   = 8080
    frontend_ip_configuration_name = "PublicIPAddress"
  }
}

lb_nat_rule = {
  lbnr1 = {
    resource_group = {
      key = "rg1"
    }
    loadbalancer = {
      key = "lb1"
    }
    name                           = "HttpAccess"
    enable_floating_ip             = false
    enable_tcp_reset               = true
    protocol                       = "Tcp"
    frontend_port                  = 8080
    backend_port                   = 8080
    frontend_ip_configuration_name = "PublicIPAddress"
  }
}

lb_outbound_rule = {
  lbor1 = {
    resource_group = {
      key = "rg1"
    }
    loadbalancer = {
      key = "lb1"
    }
    name             = "OutboundRule"
    protocol         = "Tcp"
    enable_tcp_reset = true
    backend_address_pool = {
      key = "lbap1"
    }

    frontend_ip_configuration = {
      name = "PublicIPAddress"
    }
  }
}

lb_probe = {
  lbp1 = {
    resource_group = {
      key = "rg1"
    }
    loadbalancer = {
      key = "lb1"
    }
    name = "ssh-running-probe"
    port = 22
  }
}

lb_rule = {
  lbr1 = {
    resource_group = {
      key = "rg1"
    }
    loadbalancer = {
      key = "lb1"
    }
    name                           = "LBRule"
    enable_floating_ip             = false
    enable_tcp_reset               = true
    protocol                       = "Tcp"
    frontend_port                  = 3389
    backend_port                   = 3389
    frontend_ip_configuration_name = "PublicIPAddress"
    disable_outbound_snat          = true
  }
  lbr2 = {
    resource_group = {
      key = "rg1"
    }
    loadbalancer = {
      key = "lb1"
    }
    probe = {
      key = "lbp1"
    }
    backend_address_pool = {
      lbap1 = {
        key = "lbap1"
      }
    }
    name                           = "LBRule1"
    enable_floating_ip             = true
    floating_ip_enabled            = false
    enable_tcp_reset               = true
    tcp_reset_enabled              = false
    protocol                       = "Tcp"
    frontend_port                  = 3390
    backend_port                   = 3390
    frontend_ip_configuration_name = "PublicIPAddress"
    disable_outbound_snat          = true
  }
}

load_balancers = {
  integrated = {
    name                      = "integrated"
    sku                       = "Standard"
    resource_group_key        = "rg1"
    backend_address_pool_name = "backend"
    frontend_ip_configurations = {
      primary = {
        name                  = "primary"
        public_ip_address_key = "integrated_pip"
      }
    }
    lb_rules = {
      legacy = {
        lb_rule_name                   = "legacy-load-rule"
        protocol                       = "Tcp"
        frontend_port                  = 8443
        backend_port                   = 8443
        frontend_ip_configuration_name = "primary"
        disable_outbound_snat          = true
        enable_floating_ip             = false
        enable_tcp_reset               = true
      }
      current = {
        lb_rule_name                   = "current-load-rule"
        protocol                       = "Tcp"
        frontend_port                  = 8444
        backend_port                   = 8444
        frontend_ip_configuration_name = "primary"
        disable_outbound_snat          = true
        enable_floating_ip             = true
        floating_ip_enabled            = false
        enable_tcp_reset               = true
        tcp_reset_enabled              = false
      }
    }
    nat_rules = {
      legacy = {
        name                           = "legacy-nat-rule"
        protocol                       = "Tcp"
        frontend_port                  = 8081
        backend_port                   = 8081
        frontend_ip_configuration_name = "primary"
        enable_floating_ip             = false
        enable_tcp_reset               = true
      }
    }
    outbound_rules = {
      current = {
        name              = "current-outbound-rule"
        protocol          = "Tcp"
        enable_tcp_reset  = false
        tcp_reset_enabled = true
        frontend_ip_configuration = {
          primary = { name = "primary" }
        }
      }
    }
  }
}
