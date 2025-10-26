######################################################################
# Example: Linux VM with NAT Gateway for GitHub Self-Hosted Agent
#
# This example demonstrates how to deploy a Linux VM in a subnet with
# NAT Gateway, following CAF patterns, suitable for use as a GitHub
# Actions self-hosted agent. The VM will have outbound internet access
# via NAT Gateway, but no public IP, improving security.
#
# Key points:
# - VM is deployed in a dedicated subnet with NAT Gateway attached
# - No public IP is assigned to the VM NIC (outbound only)
# - NSG allows SSH for initial setup (remove for production)
# - Custom data bootstraps the VM for GitHub Actions runner install
# - All resource names follow CAF naming conventions
######################################################################


# -------------------
# Global settings
# -------------------

global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  inherit_tags  = true
  random_length = 5
  tags = {
    environment = "dev"
    scenario    = "github-agent-nat"
  }
}


# -------------------
# Resource group
# -------------------
resource_groups = {
  agent_rg = {
    name   = "github-agent-nat-rg"
    region = "region1"
    tags = {
      purpose = "github-agent"
    }
  }
}


# -------------------
# Virtual network and subnet for the VM
# -------------------
vnets = {
  agent_vnet = {
    resource_group_key = "agent_rg"
    region             = "region1"
    vnet = {
      name          = "agent-vnet"
      address_space = ["10.10.0.0/22"]
    }
    subnets = {
      agent_subnet = {
        name = "agent-subnet"
        cidr = ["10.10.1.0/24"]
      }
    }
    specialsubnets = {}
  }
}


# -------------------
# Public IP for NAT Gateway
# -------------------
public_ip_addresses = {
  agent_nat_pip = {
    name                    = "agent-nat-pip"
    resource_group_key      = "agent_rg"
    sku                     = "Standard"
    allocation_method       = "Static"
    ip_version              = "IPv4"
    idle_timeout_in_minutes = 10
  }
}


# -------------------
# NAT Gateway
# -------------------
nat_gateways = {
  agent_nat = {
    name                    = "agent-nat"
    region                  = "region1"
    resource_group_key      = "agent_rg"
    vnet_key                = "agent_vnet"
    subnet_key              = "agent_subnet"
    public_ip_key           = "agent_nat_pip"
    idle_timeout_in_minutes = 10
  }
}


# -------------------
# Network Security Group (allow SSH, outbound internet)
# -------------------
network_security_group_definition = {
  agent_nsg = {
    name               = "agent-nsg"
    resource_group_key = "agent_rg"
    security_rules = {
      allow_ssh = {
        name                       = "Allow-SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      allow_outbound = {
        name                       = "Allow-Internet-Out"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      }
    }
  }
}


# -------------------
# Linux VM for GitHub Actions self-hosted agent
# -------------------
virtual_machines = {
  github_agent_vm = {
    resource_group_key = "agent_rg"
    os_type            = "linux"
    provision_vm_agent = true
    keyvault_key       = null # Set if using Key Vault for SSH keys
    networking_interfaces = {
      nic0 = {
        vnet_key                = "agent_vnet"
        subnet_key              = "agent_subnet"
        nsg_key                 = "agent_nsg"
        primary                 = true
        name                    = "nic0"
        enable_ip_forwarding    = false
        internal_dns_name_label = "githubagent"
        # No public IP, outbound via NAT Gateway
      }
    }
    virtual_machine_settings = {
      linux = {
        name                            = "github-agent-vm"
        size                            = "Standard_B2ms"
        admin_username                  = "azureuser"
        disable_password_authentication = true
        custom_data                     = <<CUSTOM_DATA
#cloud-config
# This script installs dependencies and prepares the VM for GitHub Actions runner.
runcmd:
  - apt-get update
  - apt-get install -y curl git jq
  - useradd -m githubagent
  - mkdir -p /home/githubagent/actions-runner
  - chown githubagent:githubagent /home/githubagent/actions-runner
  # Download GitHub Actions runner (update version as needed)
  - su - githubagent -c "cd /home/githubagent/actions-runner && curl -O -L https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz && tar xzf actions-runner-linux-x64-2.316.0.tar.gz"
  # NOTE: You must manually configure the runner registration with your repo URL and token.
  # See: https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners
CUSTOM_DATA
        network_interface_keys          = ["nic0"]
        os_disk = {
          name                 = "github-agent-osdisk"
          caching              = "ReadWrite"
          storage_account_type = "Standard_LRS"
        }
        source_image_reference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-focal"
          sku       = "20_04-lts"
          version   = "latest"
        }
        # For more details on configuring GitHub Actions runners, see:
        # https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners
      }
    }
  }
}
