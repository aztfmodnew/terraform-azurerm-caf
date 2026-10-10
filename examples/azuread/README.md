# Azure Active Directory

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

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmod/terraform-azurerm-caf/tree/main/examples/azuread).

Administrative unit settings support `members` as a set of user or group
object IDs, as well as the provider's `create`, `read`, `update`, and `delete`
timeouts. Do not manage the same administrative unit's membership through both
`members` and the separate `azuread_administrative_unit_member` resource.
Administrative unit module outputs include both the Azure resource `id` and
directory `object_id`.
