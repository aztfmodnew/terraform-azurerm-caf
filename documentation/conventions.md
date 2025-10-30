# Cloud Adoption Framework for Azure - Terraform Module development guidelines

This document summarizes our coding practices for the CAF module, they are liberally based on [https://www.terraform.io/docs/modules/index.html](https://www.terraform.io/docs/modules/index.html).

We moved from multiple modules to one unified module for CAF landing zones on Terraform. This single module will call different sub-modules each stored inside a different directory.

## Process to contribute

Module contribution workflow:

1. In the GitHub Issues, verify if there is an Epic covering the module you are describing.
2. If the change you are proposing is a sub-feature of an epic, please open an issue describing your changes in details and the reasons for the change with an example.
3. On submitting the PR, please mention the Issue related to the PR.

Checklist for module PR review:

1. Make sure you are using the Visual Studio Dev environment with pre-commit hooks effective.
2. Matching with coding conventions and common engineering criteria described below.
3. Provide examples including the main scenarios the module is supposed to achieve.
4. Include integration testing for all examples.

## Module structure

This module contain all the logic files at the root and conditionally calls sub-modules to create resources where the right variables have been customized.

### Root module file structure

The main module directory contains the following files:

| Filename         | Content                                                                                                                                                                                                                                                                                                                                                                      |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| main.tf          | Contains the version requirements, for providers, data sources if needed.                                                                                                                                                                                                                                                                                                    |
| variables.tf     | Contains the input variables for the whole module.                                                                                                                                                                                                                                                                                                                           |
| outputs.tf       | Contains the output variables for the whole module.                                                                                                                                                                                                                                                                                                                          |
| resourcenames.tf | Contains the call to the resource creation logic. This will call the sub module with all the parameters needed for the particular resource you want to deploy, inside the /module/resourcename folder. When there are a lot of resouces of the same type, they can be grouped into a subdirectory (for instance, all network-related resources are under /module/networking) |
| README.MD        | Short description of the features the module is achieving, the input and output variables.                                                                                                                                                                                                                                                                                   |
| UPGRADE.MD       | Contains upgrade instructions if anyfor module update inside a landing zone.                                                                                                                                                                                                                                                                                                 |

### Sub modules file structure

For each sub module directory, you should have the following files:

| Filename       | Content                                                                                                                                                                                                  |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| main.tf        | Contains the version requirements, for providers, data sources if needed.                                                                                                                                |
| variables.tf   | Contains the input variables for the whole module.                                                                                                                                                       |
| outputs.tf     | Contains the output variables for the whole module.                                                                                                                                                      |
| README.MD      | Short description of the features the module is achieving, the input and output variables.                                                                                                               |
| diagnostics.tf | Contains the call to the diagnostics and operations logs features for the resources created in the module. This will be called via the external diagnostics module using the arguments passed in tfvars. |

### Examples file structure and testing

Each module must have at least an example located in the `/examples` folder, that must be easy to trigger, and must work:

1. Using rover.
2. Using native Terraform.

For more information on examples and its structure, please refer to the [example documentation](./examples/README.md) and [standalone.md](./examples/standalone.md).

Each module must have at least one example located in the `/examples` folder, following the CAF standard:

- Use numbered directories for complexity: `100-xxx`, `200-xxx`, etc.
- Each example must use `configuration.tfvars` as the variable file name or multiple `*.tfvars` files.
- Examples must be easy to trigger and must work with both rover and native Terraform.

#### Mock and CI/CD Testing

- All examples must be tested using mock tests and included in CI/CD workflows.
- To run mock tests locally:
  ```bash
  terraform -chdir=examples test -test-directory=./tests/mock -var-file="<path to your configuration.tfvars>" -verbose
  ```
- All new examples must be added to the appropriate workflow file (e.g., `.github/workflows/standalone-scenarios.json`).
- Use `terraform_with_var_files` for automated plan/apply/destroy testing:
  ```bash
  terraform_with_var_files --dir /category/service/100-example/ --action plan --auto auto --workspace test
  ```

### Module Output conventions

As a convention, use the following minimal module outputs in `outputs.tf`:

| Output variable name | Content                          |
| -------------------- | -------------------------------- |
| id                   | returns the object identifiers   |
| name                 | returns the object name          |
| object               | returns the full resource object |
| rbac_id              | returns the object RBAC id       |

Add any other resource-specific outputs as needed. Mark as sensitive any output including identifiers or secrets to avoid leaking them in logs.

## CAF Engineering Criteria and Patterns

### CEC1: Using naming convention provider

Every resource created must use the naming convention provider as published on the [Terraform registry](https://registry.terraform.io/providers/aztfmodnew/azurecaf/latest)

All supported resource types are described [in the documentation](https://registry.terraform.io/providers/aztfmodnew/azurecaf/latest/docs/resources/azurecaf_name)

If you are developing a module for which there is no current support for naming convention method, please submit an issue: [https://github.com/aztfmodnew/terraform-provider-azurecaf/issues](https://github.com/aztfmodnew/terraform-provider-azurecaf/issues)

Example of naming convention provider usage to create a virtual network:

```hcl
resource "azurecaf_name" "caf_name_vnet" {

  name          = var.settings.vnet.name
  resource_type = "azurerm_virtual_network"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}
```

At the resource creation, you use the `result` output of the `azurecaf_naming_convention` provider:

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = azurecaf_name.caf_name_vnet.result
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.settings.vnet.address_space
  tags                = local.tags
}
```

Documentation for all supported field is provided in the [documentation here](https://registry.terraform.io/providers/aztfmodnew/azurecaf/latest/docs/resources/azurecaf_name)

### CEC2: Using global_settings configuration object

An object called `global_settings` is created and used by the module. It governs the creation of resources based on a set of common criteria (naming convention, prefixes, region of the deployment, name of the environment, tags inheritance settings, etc.), the content of this object is defined in `locals.tf` of the root module. The content of this variable can be customized when the module is called in order to inherit and shared the configuration settings consistently across landing zones.

The default content is:

```hcl
  global_settings = {
    prefix             = local.prefix
    prefix_with_hyphen = local.prefix == "" ? "" : "${local.prefix}-"
    prefix_start_alpha = local.prefix == "" ? "" : "${random_string.alpha1.result}${local.prefix}"
    default_region     = lookup(var.global_settings, "default_region", "region1")
    environment        = lookup(var.global_settings, "environment", var.environment)
    random_length      = try(var.global_settings.random_length, 0)
    regions            = var.global_settings.regions
    passthrough        = try(var.global_settings.passthrough, false)
    inherit_tags       = try(var.global_settings.inherit_tags, false)
    use_slug           = try(var.global_settings.use_slug, true)
  }
```

### CEC3: Iterate resource creation

At the root of the module, the call and iteration for the sub modules is declared as follow.

```hcl
module "networking" {
  source   = "./modules/networking/virtual_network"
  for_each = local.networking.vnets

  location                          = lookup(each.value, "region", null) == null ? local.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  resource_group_name               = local.resource_groups[each.value.resource_group_key].name
  settings                          = each.value
  network_security_group_definition = local.networking.network_security_group_definition
  route_tables                      = module.route_tables
  tags                              = try(each.value.tags, null)
  diagnostics                       = local.combined_diagnostics
  global_settings                   = local.global_settings
  ddos_id                           = try(azurerm_network_ddos_protection_plan.ddos_protection_plan[each.value.ddos_services_key].id, "")
  base_tags                         = try(local.global_settings.inherit_tags, false) ? local.resource_groups[each.value.resource_group_key].tags : {}
  network_watchers                  = try(local.combined_objects_network_watchers, null)
}
```

Each object within `vnets` object structure can contain one or more Virtual Network resources to be deployed.

The module's README.MD (here under ./modules/networking/virtual_network) must expose the required and optional fields inside the object iteration (iterated at `settings = each.value`)

### CEC4: Diagnostics and Private Endpoint Patterns (CAF Mandatory)

#### Diagnostics Integration

Each module that supports diagnostics must include a `diagnostics.tf` file and use the following pattern:

```hcl
module "diagnostics" {
  source            = "../../diagnostics"
  for_each          = try(var.settings.diagnostic_profiles, {})
  resource_id       = azurerm_<resource_type>.<resource_name>.id
  resource_location = azurerm_<resource_type>.<resource_name>.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = try(var.settings.diagnostic_profiles, {})
}
```

#### Private Endpoint Integration

If the service supports private endpoints, do NOT create `azurerm_private_endpoint` directly in the service module. Instead, expose the required data via outputs or `remote_objects` and instantiate the `networking/private_endpoint` submodule from the root/aggregator. See `.github/copilot-instructions.md` for the full pattern.

### CEC5: Dependency Resolution and Submodules (CAF Patterns)

- Use the coalesce pattern for all cross-module and cross-landing-zone dependencies:
  ```hcl
  resource_id = coalesce(
    try(var.settings.direct_resource_id, null),
    try(var.remote_objects.resource_name.id, null),
    try(var.remote_objects.resource_names[
      try(var.settings.resource_reference.lz_key, var.client_config.landingzone_key)
    ][var.settings.resource_reference.key].id, null)
  )
  ```
- For submodules, always pass dependencies via `remote_objects` and never as direct ID variables. Use pluralized names for module calls and outputs.

### CEC6: Backward Compatibility

When attributes are renamed or deprecated, use the `try()` pattern to support both old and new names, e.g.:

```hcl
enabled_attribute = try(
  var.settings.enabled_attribute,  # New name
  var.settings.attribute_enabled,  # Old name
  true                            # Default
)
```

Document deprecated attributes and maintain backward compatibility for at least one version.

### CEC7: Standalone resource creation

Every resource (here sub-module) should be able to be called autonomously from the Terraform registry using the following syntax:

```hcl
module "caf_virtual_machine" {
  source  = "aztfmodnew/caf/azurerm//modules/compute/virtual_machine"
  version = "4.21.2"
  # insert the 7 required variables here
}
```

### CEC8: Avoid count iterators

In order to allow reliable iterations within the modules, we recommend using `for_each` iteration and decomission usage of count for iterations as much as possible.

```hcl
resource "azurerm_log_analytics_solution" "la_solution" {
  for_each = var.solution_plan_map

    solution_name         = each.key
    location              = var.location
    resource_group_name   = var.resource_group_name
    workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
    workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    product   = each.value.product
    publisher = each.value.publisher
  }
}
```

This will allow:

1. More reliable lifecycles for resources your create iteratively.
2. Using ``key` that can be leveraged in other modules or resources iterations.
3. Better visibility in the log files.

### CEC9: Variables custom validation

Starting in Terraform 0.13, you can leverage custom variables validation. As documented [here](https://www.terraform.io/docs/configuration/variables.html) we recommend roll-out of this feature in the module.

Example: Custom validation

```hcl
variable convention {
  description = "(Required) Naming convention to use"
  type        = string
  default     = "cafrandom"

  validation {
    condition     = contains(["cafrandom", "random", "passthrough", "cafclassic"], var.convention)
    error_message = "Allowed values are cafrandom, random, passthrough or cafclassic."
  }
}
```

### CEC10: Complex objects typing

Starting in Terraform 0.14 as experimental, complex object fields can be defined optional, we recommend preparing for this feature roll-out when you write your module.

Example: Optional fields in complex objects:

```hcl
variable settings {
  description = "Configuration object for the Databricks workspace."
  type = object({
    name                        = string
    resource_group_key          = string
    sku                         = optional(string)
    managed_resource_group_name = optional(string)
    tags                        = optional(map(string))
    custom_parameters = object({
      no_public_ip       = bool
      public_subnet_key  = string
      private_subnet_key = string
      vnet_key           = string
    })
  })
}
```

## Tooling

Modules must be developed using rover version > 2006.x as it comes with required tools:

- pre-commit: adds Git hooks before commits.
- terraform_docs: automated generation of documentation.
- tfsec: security static code analysis.

## Unit, Mock, and Integration Testing

Each module must implement integration and unit testing using GitHub Actions, following the CAF patterns:

- All examples must be tested with `terraform test` using the mock framework in `examples/tests/mock`.
- Add new examples to the appropriate workflow file (e.g., `.github/workflows/standalone-scenarios.json`).
- Use `terraform_with_var_files` for automated plan/apply/destroy in CI.
- See [examples/README.md](../examples/README.md) and [standalone.md](../examples/standalone.md) for details and commands.

### GitHub Actions for Testing

New modules must automate integration testing using GitHub Actions and deploy examples in an Azure test subscription. Always ensure that all tests pass before merging.

[Back to summary](../README.md)
