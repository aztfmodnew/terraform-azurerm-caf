mock_provider "azurerm" {
  mock_resource "azurerm_databricks_workspace" {
    override_during = plan
    defaults = {
      id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Databricks/workspaces/dbw-test"
      disk_encryption_set_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/diskEncryptionSets/dbw-test"
      managed_disk_identity    = [{ principal_id = "00000000-0000-0000-0000-000000000001", tenant_id = "00000000-0000-0000-0000-000000000002", type = "SystemAssigned" }]
      storage_account_identity = [{ principal_id = "00000000-0000-0000-0000-000000000003", tenant_id = "00000000-0000-0000-0000-000000000002", type = "SystemAssigned" }]
    }
  }

  mock_resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Databricks/workspaces/dbw-test"
    }
  }
}

variables {
  global_settings = {
    prefixes      = []
    random_length = 0
    passthrough   = false
    use_slug      = true
    tags          = {}
    regions       = { region1 = "australiaeast" }
  }
  client_config = { landingzone_key = "local" }
  resource_group = {
    name     = "test-rg"
    location = "australiaeast"
    tags     = {}
  }
  resource_groups = {
    local = {
      test_rg = {
        name     = "test-rg"
        location = "australiaeast"
        tags     = {}
      }
    }
  }
  resource_group_name = "test-rg"
  location            = "australiaeast"
  base_tags           = false
  vnets = {
    local = {
      test_vnet = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet"
        subnets = {
          public  = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/public", name = "public-subnet" }
          private = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/private", name = "private-subnet" }
        }
      }
    }
  }
  aml = {
    local = {
      test_aml = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/test-aml" }
    }
  }
  diagnostics = {
    diagnostics_definition   = {}
    diagnostics_destinations = {}
    storage_accounts         = {}
    event_hub_namespaces     = {}
    log_analytics            = {}
  }
  private_endpoints = {}
  private_dns       = {}
  remote_objects = {
    keyvault_keys = {
      local = {
        managed_services = { id = "https://test.vault.azure.net/keys/managed-services/0123456789abcdef0123456789abcdef" }
        managed_disk     = { id = "https://test.vault.azure.net/keys/managed-disk/0123456789abcdef0123456789abcdef" }
        dbfs             = { id = "https://test.vault.azure.net/keys/dbfs/0123456789abcdef0123456789abcdef" }
      }
    }
    databricks_access_connectors = {
      local = {
        test_connector = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Databricks/accessConnectors/test" }
      }
    }
  }
}

run "workspace_provider_options_and_dbfs_key_are_resolved" {
  command = plan

  module {
    source = "../modules/analytics/databricks_workspace"
  }

  variables {
    settings = {
      name                              = "dbw-test"
      sku                               = "premium"
      resource_group_key                = "test_rg"
      customer_managed_key_enabled      = true
      infrastructure_encryption_enabled = true
      managed_services_cmk_key = {
        key = "managed_services"
      }
      managed_disk_cmk_key = {
        key = "managed_disk"
      }
      managed_disk_cmk_rotation_to_latest_version_enabled = true
      load_balancer_backend_address_pool_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/loadBalancers/test/backendAddressPools/outbound"
      public_network_access_enabled                       = false
      network_security_group_rules_required               = "NoAzureDatabricksRules"
      default_storage_firewall_enabled                    = true
      access_connector = {
        key = "test_connector"
      }
      custom_parameters = {
        no_public_ip             = true
        nat_gateway_name         = "test-nat"
        public_ip_name           = "test-public-ip"
        storage_account_name     = "teststorage"
        storage_account_sku_name = "Standard_LRS"
        vnet_key                 = "test_vnet"
        public_subnet_key        = "public"
        private_subnet_key       = "private"
        machine_learning_workspace = {
          key = "test_aml"
        }
      }
      enhanced_security_compliance = {
        automatic_cluster_update_enabled      = true
        compliance_security_profile_enabled   = true
        compliance_security_profile_standards = ["HIPAA"]
        enhanced_security_monitoring_enabled  = true
      }
      root_dbfs_customer_managed_key = {
        key_vault_key = {
          key = "dbfs"
        }
      }
      timeouts = {
        create = "45m"
        read   = "10m"
        update = "45m"
        delete = "50m"
      }
    }
    remote_objects = var.remote_objects
    vnets          = var.vnets
    aml            = var.aml
  }

  assert {
    condition = (
      azurerm_databricks_workspace.ws.load_balancer_backend_address_pool_id != null &&
      azurerm_databricks_workspace.ws.managed_services_cmk_key_vault_key_id == var.remote_objects.keyvault_keys.local.managed_services.id &&
      azurerm_databricks_workspace.ws.managed_disk_cmk_key_vault_key_id == var.remote_objects.keyvault_keys.local.managed_disk.id &&
      azurerm_databricks_workspace.ws.access_connector_id == var.remote_objects.databricks_access_connectors.local.test_connector.id
    )
    error_message = "Workspace provider arguments must accept load balancer, CMK key references, and Access Connector references."
  }

  assert {
    condition = (
      azurerm_databricks_workspace.ws.custom_parameters[0].virtual_network_id == var.vnets.local.test_vnet.id &&
      azurerm_databricks_workspace.ws.custom_parameters[0].public_subnet_name == var.vnets.local.test_vnet.subnets.public.name &&
      azurerm_databricks_workspace.ws.custom_parameters[0].private_subnet_network_security_group_association_id == var.vnets.local.test_vnet.subnets.private.id &&
      azurerm_databricks_workspace.ws.custom_parameters[0].machine_learning_workspace_id == var.aml.local.test_aml.id
    )
    error_message = "Custom parameters must resolve network subnets and the Azure Machine Learning workspace from CAF keys."
  }

  assert {
    condition = (
      azurerm_databricks_workspace.ws.enhanced_security_compliance[0].compliance_security_profile_enabled &&
      contains(azurerm_databricks_workspace.ws.enhanced_security_compliance[0].compliance_security_profile_standards, "HIPAA") &&
      azurerm_databricks_workspace_root_dbfs_customer_managed_key.root_dbfs["root_dbfs"].workspace_id == azurerm_databricks_workspace.ws.id &&
      azurerm_databricks_workspace_root_dbfs_customer_managed_key.root_dbfs["root_dbfs"].key_vault_key_id == var.remote_objects.keyvault_keys.local.dbfs.id
    )
    error_message = "Enhanced security settings and the optional root DBFS key resource must be configured."
  }

  assert {
    condition = (
      output.disk_encryption_set_id == azurerm_databricks_workspace.ws.disk_encryption_set_id &&
      output.managed_disk_identity.principal_id == "00000000-0000-0000-0000-000000000001" &&
      output.storage_account_identity.principal_id == "00000000-0000-0000-0000-000000000003" &&
      output.root_dbfs_customer_managed_key_id == azurerm_databricks_workspace_root_dbfs_customer_managed_key.root_dbfs["root_dbfs"].id
    )
    error_message = "The module must expose the provider's encryption identities and the optional DBFS key resource ID."
  }
}

run "legacy_machine_learning_key_reference_is_preserved" {
  command = plan

  module {
    source = "../modules/analytics/databricks_workspace"
  }

  variables {
    settings = {
      name               = "dbw-legacy-aml"
      resource_group_key = "test_rg"
      machine_learning = {
        key = "test_aml"
      }
      custom_parameters = {
        no_public_ip = false
      }
    }
    remote_objects = var.remote_objects
    vnets          = var.vnets
    aml            = var.aml
  }

  assert {
    condition = (
      azurerm_databricks_workspace.ws.custom_parameters[0].machine_learning_workspace_id == var.aml.local.test_aml.id &&
      azurerm_databricks_workspace.ws.sku == "standard" &&
      azurerm_databricks_workspace.ws.custom_parameters[0].no_public_ip == false
    )
    error_message = "The legacy machine_learning key reference, standard SKU default, and no_public_ip=false default must be preserved."
  }
}
