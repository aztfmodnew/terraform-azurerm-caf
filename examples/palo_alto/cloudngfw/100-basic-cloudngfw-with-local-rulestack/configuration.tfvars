# examples/networking/palo_alto_ngfw_vnet_local_rulestack/100-basic-ngfw-with-local-rulestack/configuration.tfvars

resource_groups = {
  ngfw_rg = {
    name     = "ngfw-example-basic"
    location = "westeurope" # Change to your desired region
  }
}

vnets = {
  ngfw_vnet = {
    resource_group_key = "ngfw_rg"
    location           = "westeurope" # Or inherit from RG
    vnet = {
      name          = "vnet-ngfw-example"
      address_space = ["10.100.0.0/16"]
    }
    subnets = {
      snet_management = {
        name = "snet-ngfw-mgmt"
        cidr = ["10.100.1.0/24"]
      }
      snet_trust = {
        name    = "snet-ngfw-trust"
        cidr    = ["10.100.2.0/24"]
        nsg_key = "ngfw_trust_nsg"
        delegation = {
          name               = "PaloAltoNetworks.Cloudngfw/firewalls"
          service_delegation = "PaloAltoNetworks.Cloudngfw/firewalls"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        }
      }
      snet_untrust = {
        name    = "snet-ngfw-untrust"
        cidr    = ["10.100.3.0/24"]
        nsg_key = "ngfw_untrust_nsg"
        delegation = {
          name               = "PaloAltoNetworks.Cloudngfw/firewalls"
          service_delegation = "PaloAltoNetworks.Cloudngfw/firewalls"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        }
      }
      // AzureBastionSubnet if you plan to use Bastion for VM access
      // AzureBastionSubnet = {
      //   name           = "AzureBastionSubnet"
      //   address_prefix = "10.100.4.0/24"
      // }
    }
    tags = {
      purpose = "NGFW VNet"
    }
  }
}

public_ip_addresses = {
  ngfw_pip_management = {
    name               = "pip-ngfw-mgmt"
    resource_group_key = "ngfw_rg"
    location           = "westeurope" # Or inherit from RG
    allocation_method  = "Static"
    sku                = "Standard"
    tags = {
      purpose = "NGFW Management PIP"
    }
  }
  ngfw_pip_dataplane1 = {
    name               = "pip-ngfw-dp1"
    resource_group_key = "ngfw_rg"
    location           = "westeurope" # Or inherit from RG
    allocation_method  = "Static"
    sku                = "Standard"
    tags = {
      purpose = "NGFW Dataplane PIP"
    }
  }
  // Add more PIPs if the NGFW requires multiple for its dataplane or HA
}

network_security_group_definition = {
  ngfw_trust_nsg = {
    nsg = []
  },
  ngfw_untrust_nsg = {
    nsg = []
  }
}

palo_alto_cloudngfws = {
  basic_ngfw_instance = {
    name               = "pangfw-basic-example"
    resource_group_key = "ngfw_rg"   // Key of the resource group defined above
    attachment_type    = "vnet"      // or "vwan" depending on your architecture
    management_mode    = "rulestack" // or "panorama" depending on your architecture
    # location            = "westeurope" # Optional, will inherit from resource_group if not specified

    network_profile = {
      vnet_configuration = {
        virtual_network_key = "ngfw_vnet" // Key of the VNet defined above
        // The Palo Alto NGFW module might require specific subnet keys or roles to be identified.
        // For example, if the module expects keys like 'management_subnet_key', 'trust_subnet_key', etc.
        // you would add them here, mapping to the subnet keys defined in virtual_networks.ngfw_vnet.subnets.
        // This depends on how the Palo Alto module is designed to consume subnet information.
        // For now, we assume the module can derive necessary subnets from the virtual_network_key
        // or that specific subnet IDs are not explicitly required at this top level of vnet_configuration.
        // If direct subnet IDs are needed by the resource, the module would need to be adapted
        // to look them up from the VNet object using these keys.
        trusted_subnet_key   = "snet_trust"   // Key of the trusted subnet defined above
        untrusted_subnet_key = "snet_untrust" // Key of the untrusted subnet defined above
        // If the module requires specific subnet IDs, you can also provide them here
        // trusted_subnet_id   = "subnet-trust-id"
        // untrusted_subnet_id = "subnet-untrust-id"
      }
      public_ip_address_keys = [
        {
          # lz_key is optional and can be used to specify the landing zone key
          # lz_key = "my_landingzone" # Optional, if the PIP is in a different landing zone
          key = "ngfw_pip_management" # Clave de la PIP dentro de esa landing zone
        },
        {
          # lz_key = "my_landingzone"
          key = "ngfw_pip_dataplane1"
        },
        # Add more PIPs if needed
        # {
        #   lz_key = "another_landingzone"
        #   key    = "some_other_pip_key"
        # }
      ] // Keys of PIPs defined above
      enable_egress_nat = true
    }


    local_rulestack = {
      name        = "localrules-basic-example"
      description = "Basic local rulestack for the example NGFW."
      # location    = "westeurope" # Optional, will inherit from the NGFW if not specified
    }

    tags = {
      environment = "example"
      cost_center = "it"
    }
  }
}

# Note: This example now defines the VNet and Public IPs.
# The Palo Alto NGFW module will need to be adapted to look up the IDs of these resources
# using the provided keys (e.g., virtual_network_key, public_ip_address_keys)
# from the remote_objects passed to it.
# Consult the module's documentation for all configurable parameters.
