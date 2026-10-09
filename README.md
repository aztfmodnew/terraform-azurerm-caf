# Cloud Adoption Framework for Azure - Terraform module

[![PR all-tests](https://github.com/aztfmodnew/terraform-azurerm-caf/actions/workflows/pr_tests-scenarios.yaml/badge.svg)](https://github.com/aztfmodnew/terraform-azurerm-caf/actions/workflows/pr_tests-scenarios.yaml)
[![Monthly Integration tests](https://github.com/aztfmodnew/terraform-azurerm-caf/actions/workflows/weekly_workflow.yaml/badge.svg)](https://github.com/aztfmodnew/terraform-azurerm-caf/actions/workflows/monthly_workflow.yaml)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/aztfmodnew/terraform-azurerm-caf)

> 🏗️ **New to this repository?** Start with [.github/AGENTS.md](.github/AGENTS.md) for AI agents and [Project_Architecture_Blueprint.md](Project_Architecture_Blueprint.md) for architecture navigation.

> :warning: This is a community-maintained continuation of the Azure CAF modules. This solution is offered by the Open-Source community and is not supported by Microsoft. It's a community effort to keep the project alive and up to date. If you want to support the project, please consider contributing with code, documentation or any other way you can.

This module allows you to create resources on Microsoft Azure, is used by the Azure Terraform SRE to provision resources in an Azure subscription and can deploy resources being directly invoked from the Terraform registry.

## Prerequisites

- Setup your **environment** using the following guide [Getting Started](https://github.com/aztfmodnew/caf-terraform-landingzones/blob/main/documentation/getting_started/getting_started.md) or you use it online with [GitHub Codespaces](https://github.com/features/codespaces).
- Access to an **Azure subscription**.

## Getting started

This module can be used inside [:books: Azure Terraform Landing zones](https://github.com/aztfmodnew/caf-terraform-landingzones), or can be used as standalone, directly from the [Terraform registry](https://registry.terraform.io/modules/aztfmodnew/caf/azurerm/)

```terraform
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.26.0"
  # insert the 7 required variables here
}
```

Fill the variables as needed and documented, there is a [quick example here](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/master/examples/standalone.md) or [complete example here](https://github.com/aztfmodnew/terraform-azurerm-caf-deployments).

For a complete set of examples you can review the [full library here](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/master/examples).


## 📚 Documentation

The full documentation for all modules, usage, and dependency diagrams is published automatically:

- **[CAF Terraform Documentation (MkDocs)](https://aztfmodnew.github.io/terraform-azurerm-caf/)**

### AzAPI root settings

AzAPI configuration and version constraints are centralized in the root;
modules using AzAPI declare only its `azure/azapi` source requirement.

VNet peerings retain direct IDs and CAF key references. Optional
`peer_complete_vnets`, `enable_only_ipv6_peering`, local/remote subnet names,
address spaces (including IPAM pool prefixes), BGP communities, peering state
and sync level, and CRUD timeouts are supported. Existing defaults are unchanged.
See the [peering example](examples/networking/virtual_network/103-vnet-peering-v1/configuration.tfvars).

Storage CMK vault lookups retain direct, name-based, remote landing-zone and
sovereign-cloud resolution. `customer_managed_key.vault_lookup_timeouts.read`
optionally controls the ARM vault lookup; `properties.vaultUri` remains its
exported endpoint.

Every merge to the `main` branch automatically updates the documentation site.

---
## Community

Feel free to open an issue for feature or bug, or to submit a PR, [Please check out the WIKI for coding standards, common patterns and PR checklist.](https://github.com/aztfmodnew/terraform-azurerm-caf/wiki)

You can also reach us on [GitHub Discussions](https://github.com/aztfmodnew/terraform-azurerm-caf/discussions).

## Contributing

This project welcomes contributions and suggestions.

---
