# Cloud Adoption Framework for Azure - Terraform module

> :warning: This solution, offered by the Open-Source community, it's based on [https://github.com/aztfmod](https://github.com/aztfmod) and is not supported by Microsoft. It's a community effort to keep the project alive and up to date. If you want to support the project, please consider contributing with code, documentation or any other way you can.

This module allows you to create resources on Microsoft Azure, is used by the Azure Terraform SRE to provision resources in an Azure subscription and can deploy resources being directly invoked from the Terraform registry.

## Prerequisites

- Setup your **environment** using the following guide [Getting Started](https://github.com/aztfmod/caf-terraform-landingzones/blob/master/documentation/getting_started/getting_started.md) or you use it online with [GitHub Codespaces](https://github.com/features/codespaces).
- Access to an **Azure subscription**.

## Getting started

This module can be used inside [:books: Azure Terraform Landing zones](https://aztfmod.github.io/documentation/), or can be used as standalone, directly from the [Terraform registry](https://registry.terraform.io/modules/aztfmodnew/caf/azurerm/)

```terraform
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.26.0"
  # insert the 7 required variables here
}
```

Fill the variables as needed and documented, there is a [quick example here](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/master/examples/standalone.md) or [complete example here](https://github.com/aztfmodnew/terraform-azurerm-caf-deployments).

For a complete set of examples you can review the [full library here](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/master/examples).

## Community

Feel free to open an issue for feature or bug, or to submit a PR, [Please check out the WIKI for coding standards, common patterns and PR checklist.](https://github.com/aztfmodnew/terraform-azurerm-caf/wiki)

WIP - You can also reach us on [Gitter](https://gitter.im/aztfmodnew/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

## Contributing

This project welcomes contributions and suggestions.

---
