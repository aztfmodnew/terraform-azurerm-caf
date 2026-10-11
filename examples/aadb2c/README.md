# Azure Active Directory B2C

This module is part of Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate this directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.26.1"

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

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/master/examples/aadb2c).

The `aadb2c_directory` settings accept optional `timeouts` for `create`, `read`,
`update`, and `delete`. Their provider defaults are 30 minutes, 5 minutes,
30 minutes, and 30 minutes respectively. The module outputs `id`, `tenant_id`,
`billing_type`, and `effective_start_date`; the effective date may be unset
until after the first billing cycle.
