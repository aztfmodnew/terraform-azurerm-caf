global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  aks_re1 = {
    name   = "aks-re1"
    region = "region1"
  }
  msi_region1 = {
    name   = "security-rg1"
    region = "region1"
  }
}

aks_clusters = {
  cluster_re1 = {
    name               = "akscluster-re1-001"
    resource_group_key = "aks_re1"
    os_type            = "Linux"

    identity = {
      type = "SystemAssigned"
    }

    vnet_key = "spoke_aks_re1"

    network_profile = {
      network_plugin    = "azure"
      load_balancer_sku = "standard"
    }

    role_based_access_control = {
      enabled = true
      azure_active_directory = {
        managed = true
      }
    }

    oms_agent = {
      log_analytics_key = "central_logs_region1"
    }

    load_balancer_profile = {
      managed_outbound_ip_count = 1
    }

    default_node_pool = {
      name = "sharedsvc"
      vm_size = "Standard_F4s_v2"
      subnet = {
        key = "aks_nodepool_system"
      }
      enabled_auto_scaling  = false
      enable_node_public_ip = false
      max_pods              = 30
      node_count            = 1
      os_disk_size_gb       = 512
      tags = {
        "project" = "system services"
      }
    }

    node_resource_group_name = "aks-nodes-re1"

    addon_profile = {
      azure_keyvault_secrets_provider = {
        secret_rotation_enabled  = true
        secret_rotation_interval = "2m"
      }
    }

    oidc_issuer_enabled       = true
    workload_identity_enabled = true

    mi_federated_credentials = {
      cred1 = {
        name    = "mi-wi-demo02"
        subject = "system:serviceaccount:demo:workload-identity-sa"
        managed_identity = {
          key = "workload_system_mi"
        }
      }
    }
  }
}

managed_identities = {
  workload_system_mi = {
    name               = "demo-mi-wi"
    resource_group_key = "msi_region1"
  }
}

diagnostic_log_analytics = {
  central_logs_region1 = {
    region             = "region1"
    name               = "logs"
    resource_group_key = "aks_re1"
  }
}

vnets = {
  spoke_aks_re1 = {
    resource_group_key = "aks_re1"
    region             = "region1"
    vnet = {
      name          = "aks"
      address_space = ["100.64.48.0/22"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name    = "aks_nodepool_system"
        cidr    = ["100.64.48.0/24"]
        nsg_key = "azure_kubernetes_cluster_nsg"
      }
      aks_nodepool_user1 = {
        name    = "aks_nodepool_user1"
        cidr    = ["100.64.49.0/24"]
        nsg_key = "azure_kubernetes_cluster_nsg"
      }
    }
  }
}

network_security_group_definition = {
  empty_nsg = {}
  azure_kubernetes_cluster_nsg = {
    nsg = [
      {
        name                       = "aks-https-in-allow",
        priority                   = "110"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    ]
  }
}
