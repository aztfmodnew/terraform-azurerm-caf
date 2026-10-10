mock_provider "azurerm" {
  mock_resource "azurerm_machine_learning_compute_instance" {
    override_during = plan
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/aml-test/computes/aml-compute-contract"
      identity = {
        type         = "SystemAssigned, UserAssigned"
        principal_id = "00000000-0000-0000-0000-000000000010"
        tenant_id    = "00000000-0000-0000-0000-000000000001"
      }
    }
  }
}

variables {
  global_settings = {
    prefixes      = []
    suffixes      = []
    random_length = 0
    passthrough   = true
    use_slug      = false
  }
  client_config = {
    landingzone_key = "local"
    tenant_id       = "00000000-0000-0000-0000-000000000001"
  }
  location = "australiaeast"
  base_tags = {
    environment = "test"
    cost_center = "analytics"
  }
  workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/aml-test"
  subnet_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aml"
  remote_objects = {
    machine_learning_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/aml-test"
    managed_identities = {
      local = {
        aml_identity = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aml"
        }
      }
      remote = {
        shared_identity = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/shared-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/shared"
        }
      }
    }
  }
}

run "all_compute_instance_options_and_outputs_are_supported" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning_compute_instance"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    location        = var.location
    base_tags       = var.base_tags
    remote_objects  = var.remote_objects
    settings = {
      name = "aml-compute-contract"
      machine_learning_workspace = {
        id = var.workspace_id
      }
      virtual_machine_size = "STANDARD_DS2_V2"
      authorization_type   = "personal"
      assign_to_user = {
        object_id = "00000000-0000-0000-0000-000000000020"
      }
      description        = "Compute instance contract"
      local_auth_enabled = false
      identity = {
        type                  = "SystemAssigned, UserAssigned"
        identity_ids          = []
        managed_identity_keys = ["aml_identity"]
        remote = {
          remote = {
            managed_identity_keys = ["shared_identity"]
          }
        }
      }
      ssh = {
        public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ== test@example"
      }
      subnet_resource_id     = var.subnet_id
      node_public_ip_enabled = false
      tags                   = { owner = "analytics-team" }
      timeouts = {
        create = "35m"
        read   = "7m"
        delete = "35m"
      }
    }
  }

  assert {
    condition = (
      azurerm_machine_learning_compute_instance.mlci.machine_learning_workspace_id == var.workspace_id &&
      azurerm_machine_learning_compute_instance.mlci.virtual_machine_size == "STANDARD_DS2_V2" &&
      azurerm_machine_learning_compute_instance.mlci.authorization_type == "personal" &&
      azurerm_machine_learning_compute_instance.mlci.description == "Compute instance contract" &&
      azurerm_machine_learning_compute_instance.mlci.local_auth_enabled == false &&
      azurerm_machine_learning_compute_instance.mlci.node_public_ip_enabled == false &&
      azurerm_machine_learning_compute_instance.mlci.subnet_resource_id == var.subnet_id &&
      azurerm_machine_learning_compute_instance.mlci.assign_to_user[0].object_id == "00000000-0000-0000-0000-000000000020" &&
      azurerm_machine_learning_compute_instance.mlci.assign_to_user[0].tenant_id == var.client_config.tenant_id &&
      length(azurerm_machine_learning_compute_instance.mlci.identity[0].identity_ids) == 2 &&
      contains(azurerm_machine_learning_compute_instance.mlci.identity[0].identity_ids, var.remote_objects.managed_identities.local.aml_identity.id) &&
      contains(azurerm_machine_learning_compute_instance.mlci.identity[0].identity_ids, var.remote_objects.managed_identities.remote.shared_identity.id) &&
      azurerm_machine_learning_compute_instance.mlci.ssh[0].public_key == "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ== test@example" &&
      azurerm_machine_learning_compute_instance.mlci.tags.environment == "test" &&
      azurerm_machine_learning_compute_instance.mlci.tags.cost_center == "analytics" &&
      azurerm_machine_learning_compute_instance.mlci.tags.owner == "analytics-team"
    )
    error_message = "The module must pass all provider options, resolved identity references, and merged tags."
  }

  assert {
    condition = (
      output.id == azurerm_machine_learning_compute_instance.mlci.id &&
      output.rbac_id == "00000000-0000-0000-0000-000000000010" &&
      output.identity[0].type == "SystemAssigned, UserAssigned" &&
      output.ssh[0].public_key == "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ== test@example"
    )
    error_message = "The module must expose the compute instance ID, identity, SSH settings, and RBAC principal."
  }
}

run "provider_defaults_are_preserved_when_options_are_omitted" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning_compute_instance"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    location        = var.location
    base_tags       = var.base_tags
    remote_objects  = var.remote_objects
    settings = {
      name = "aml-compute-defaults"
      machine_learning_workspace = {
        key = "aml-test"
      }
      virtual_machine_size = "STANDARD_DS2_V2"
    }
  }

  assert {
    condition = (
      azurerm_machine_learning_compute_instance.mlci.local_auth_enabled == true &&
      azurerm_machine_learning_compute_instance.mlci.node_public_ip_enabled == true &&
      azurerm_machine_learning_compute_instance.mlci.subnet_resource_id == null &&
      azurerm_machine_learning_compute_instance.mlci.authorization_type == null &&
      azurerm_machine_learning_compute_instance.mlci.tags.module == "machine_learning_compute_instance"
    )
    error_message = "Omitted compute options must retain the AzureRM defaults and CAF module tag."
  }
}

run "direct_user_assigned_identity_ids_are_supported" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning_compute_instance"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    location        = var.location
    base_tags       = var.base_tags
    remote_objects  = var.remote_objects
    settings = {
      name = "aml-compute-direct-identity"
      machine_learning_workspace = {
        id = var.workspace_id
      }
      virtual_machine_size = "STANDARD_DS2_V2"
      identity = {
        type         = "UserAssigned"
        identity_ids = [var.remote_objects.managed_identities.local.aml_identity.id]
      }
    }
  }

  assert {
    condition = (
      length(azurerm_machine_learning_compute_instance.mlci.identity[0].identity_ids) == 1 &&
      contains(
        azurerm_machine_learning_compute_instance.mlci.identity[0].identity_ids,
        var.remote_objects.managed_identities.local.aml_identity.id
      )
    )
    error_message = "The module must accept direct user-assigned identity IDs."
  }
}

run "legacy_resolved_workspace_id_without_workspace_setting_is_supported" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning_compute_instance"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    location        = var.location
    base_tags       = var.base_tags
    remote_objects  = var.remote_objects
    settings = {
      name                 = "aml-compute-legacy"
      virtual_machine_size = "STANDARD_DS2_V2"
    }
  }

  assert {
    condition     = azurerm_machine_learning_compute_instance.mlci.machine_learning_workspace_id == var.remote_objects.machine_learning_workspace_id
    error_message = "Callers passing only remote_objects.machine_learning_workspace_id must keep working without a duplicate settings.machine_learning_workspace reference."
  }
}

run "workspace_reference_without_id_or_key_is_rejected" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning_compute_instance"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    location        = var.location
    base_tags       = var.base_tags
    remote_objects  = var.remote_objects
    settings = {
      name                       = "aml-compute-bad-workspace"
      machine_learning_workspace = {}
      virtual_machine_size       = "STANDARD_DS2_V2"
    }
  }

  expect_failures = [var.settings]
}

run "incomplete_subnet_reference_is_rejected" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning_compute_instance"
  }

  variables {
    global_settings = var.global_settings
    client_config   = var.client_config
    location        = var.location
    base_tags       = var.base_tags
    remote_objects  = var.remote_objects
    settings = {
      name                 = "aml-compute-bad-subnet"
      virtual_machine_size = "STANDARD_DS2_V2"
      subnet = {
        key = "aml"
      }
    }
  }

  expect_failures = [var.settings]
}
