global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
  random_length = 5
  inherit_tags  = true
  tags = {
    example = "examples/networking/private_dns/100-private-dns-vnet-links"
  }
}


resource_groups = {
  private_dns_region1 = {
    name   = "private-dns-rg"
    region = "region1"
  }
}

vnets = {
  vnet_test = {
    resource_group_key = "private_dns_region1"
    vnet = {
      name          = "test-vnet"
      address_space = ["10.10.100.0/24"]
    }
    specialsubnets = {

    }
    subnets = {

    }
  }
}

private_dns = {
  dns1 = {
    name               = "test-dns.mysite.com"
    resource_group_key = "private_dns_region1"

    records = {
      aaaa_records = {
        ipv6 = {
          name    = "ipv6"
          ttl     = 300
          records = ["fd00::10"]
        }
      }
      cname_records = {
        alias = {
          name    = "alias"
          ttl     = 300
          records = "host.test-dns.mysite.com"
        }
      }
      mx_records = {
        mail = {
          name = "@"
          ttl  = 300
          records = {
            primary = { preference = 10, exchange = "mail.test-dns.mysite.com" }
          }
        }
      }
      srv_records = {
        service = {
          name = "_https._tcp"
          ttl  = 300
          records = {
            primary = { priority = 10, weight = 5, port = 443, target = "host.test-dns.mysite.com" }
          }
        }
      }
      a_records = {
        testa1 = {
          name    = "*"
          ttl     = 3600
          records = ["1.1.1.1", "2.2.2.2"]
          tags = {
            resource = "a_records"
          }
        }
        testa2 = {
          name    = "@"
          ttl     = 3600
          records = ["1.1.1.1", "2.2.2.2"]
        }
      }

      txt_records = {
        testtxt1 = {
          name = "testtxt1"
          ttl  = 3600
          records = {
            r1 = {
              value = "testing txt 1"
              tags = {
                resource = "txt_records"
              }
            }
            r2 = {
              value = "testing txt 2"
            }
          }
        }
      }
    }

    vnet_links = {
      link_test = {
        name     = "test-vnet-link"
        vnet_key = "vnet_test"
        tags = {
          resource = "vnet_links"
        }
      }
      # link_hub = {
      #   name = "hub-vnet-link"
      #   remote_tfstate = {
      #     tfstate_key = "networking_hub"
      #     lz_key      = "networking_hub"
      #     output_key  = "vnets"
      #     vnet_key    = "hub_rg1"
      #   }
      # }
    }
  }
  reverse = {
    name               = "100.10.10.in-addr.arpa"
    resource_group_key = "private_dns_region1"
    records = {
      ptr_records = {
        host = {
          name    = "10"
          ttl     = 300
          records = ["host.test-dns.mysite.com"]
        }
      }
    }
  }
}

private_dns_vnet_links = {
  reverse = {
    vnet_key = "vnet_test"
    private_dns_zones = {
      reverse = {
        name = "reverse-link"
        key  = "reverse"
      }
    }
  }
}