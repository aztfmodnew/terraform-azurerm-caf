mock_provider "azurerm" {
  mock_resource "azurerm_resource_group_template_deployment" {
    override_during = plan
    defaults = {
      id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Resources/deployments/aml-compute-test"
      output_content = "{\"exampleOutput\":{\"type\":\"string\",\"value\":\"contract-output\"}}"
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
  machine_learning_workspace_name = "aml-test"
  subnet_id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aml"
  resource_group_name             = "test-rg"
  location                        = "australiaeast"
  tags = {
    environment = "test"
    cost_center = "analytics"
  }
}

run "deployment_options_tags_and_outputs_are_supported" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning/compute_instance"
  }

  variables {
    global_settings                 = var.global_settings
    machine_learning_workspace_name = var.machine_learning_workspace_name
    subnet_id                       = var.subnet_id
    resource_group_name             = var.resource_group_name
    location                        = var.location
    tags                            = var.tags
    settings = {
      computeInstanceName   = "aml-compute-contract"
      vmSize                = "Standard_DS3_v2"
      adminUserName         = "azureuser"
      sshAccess             = "Disabled"
      adminUserSshPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ== test@example"
      debug_level           = "responseContent"
      tags                  = { owner = "analytics-team" }
      timeouts = {
        create = "45m"
        read   = "8m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_resource_group_template_deployment.mlci.resource_group_name == var.resource_group_name &&
      azurerm_resource_group_template_deployment.mlci.deployment_mode == "Incremental" &&
      azurerm_resource_group_template_deployment.mlci.debug_level == "responseContent" &&
      azurerm_resource_group_template_deployment.mlci.tags.environment == "test" &&
      azurerm_resource_group_template_deployment.mlci.tags.cost_center == "analytics" &&
      azurerm_resource_group_template_deployment.mlci.tags.owner == "analytics-team" &&
      strcontains(azurerm_resource_group_template_deployment.mlci.template_content, "Microsoft.MachineLearningServices/workspaces/computes")
    )
    error_message = "The nested module must pass supported deployment arguments and merge inherited and per-instance tags."
  }

  assert {
    condition = (
      output.id == azurerm_resource_group_template_deployment.mlci.id &&
      output.output_content == "{\"exampleOutput\":{\"type\":\"string\",\"value\":\"contract-output\"}}"
    )
    error_message = "The nested module must expose the template deployment ID and output content."
  }

  assert {
    condition = (
      azurerm_resource_group_template_deployment.mlci.timeouts.create == "45m" &&
      azurerm_resource_group_template_deployment.mlci.timeouts.read == "8m" &&
      azurerm_resource_group_template_deployment.mlci.timeouts.update == "45m" &&
      azurerm_resource_group_template_deployment.mlci.timeouts.delete == "45m"
    )
    error_message = "Custom timeouts must be forwarded to the template deployment."
  }
}

run "deployment_defaults_are_preserved_when_options_are_omitted" {
  command = plan

  module {
    source = "../modules/analytics/machine_learning/compute_instance"
  }

  variables {
    global_settings                 = var.global_settings
    machine_learning_workspace_name = var.machine_learning_workspace_name
    subnet_id                       = var.subnet_id
    resource_group_name             = var.resource_group_name
    location                        = var.location
    tags                            = var.tags
    settings = {
      computeInstanceName   = "aml-compute-defaults"
      vmSize                = "Standard_DS3_v2"
      adminUserName         = "azureuser"
      sshAccess             = "Disabled"
      adminUserSshPublicKey = ""
    }
  }

  assert {
    condition = (
      azurerm_resource_group_template_deployment.mlci.deployment_mode == "Incremental" &&
      azurerm_resource_group_template_deployment.mlci.debug_level == null &&
      azurerm_resource_group_template_deployment.mlci.tags.environment == "test" &&
      azurerm_resource_group_template_deployment.mlci.tags.module == "compute_instance"
    )
    error_message = "Omitting optional deployment settings must preserve incremental mode and inherited CAF tags."
  }

  assert {
    condition = (
      azurerm_resource_group_template_deployment.mlci.timeouts.create == "10h" &&
      azurerm_resource_group_template_deployment.mlci.timeouts.read == "5m" &&
      azurerm_resource_group_template_deployment.mlci.timeouts.update == "10h" &&
      azurerm_resource_group_template_deployment.mlci.timeouts.delete == "10h"
    )
    error_message = "Omitting timeouts must preserve the historical 10h/5m deployment timeouts."
  }
}
