# Azure Active Directory Domain Services

This module is part of Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate this directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.30.0"

  # Add object as described below
}
```

CAF Terraform module is iterative by default, you can instantiate as many objects as needed, using the following structure:

```hcl
resource_to_be_created = {
  object1 = {
    #configuration details as below
  }
  object2 = {
    #configuration details as below
  }
}
```

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/main/examples/identity/active_directory_domain_service).

You can also review an example of how to use this module in the [CAF deployments repository](https://github.com/aztfmodnew/terraform-azurerm-caf-deployments)
