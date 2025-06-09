# App Configuration (app_config)

This module is part of the Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate it directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.30.0"
  app_config = var.app_config
  # You can add other objects as needed, e.g. resource_groups = var.resource_groups
}
```

The CAF Terraform module is iterative by default; you can instantiate as many objects as needed using the following structure:

```hcl
resource_to_be_created = {
  object1 = {
    # configuration details
  }
  object2 = {
    # configuration details
  }
}
```

You can review the complete set of examples in the [GitHub repository](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/main/examples/app_config).

---

## Inputs

| Name           | Description                                                                                     | Type   | Required |
| -------------- | ----------------------------------------------------------------------------------------------- | ------ | :------: |
| name           | Specifies the name of the App Configuration. Changing this forces a new resource to be created. |        |   True   |
| resource_group | The `resource_group` block as defined below.                                                    | Block  |   True   |
| region         | The region_key where the resource will be deployed                                              | String |   True   |
| sku            | The SKU name of the the App Configuration. Possible values are `free` and `standard`.           |        |  False   |
| identity       | An `identity` block as defined below.                                                           | Block  |  False   |
| tags           | A mapping of tags to assign to the resource.                                                    |        |  False   |

## Blocks

| Block          | Argument     | Description                                                                                                                                                                                                     | Required |
| -------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --- | ----------- |
| resource_group | key          | Key for resource_group                                                                                                                                                                                          |          |     | Required if |
| resource_group | lz_key       | Landing Zone Key in wich the resource_group is located                                                                                                                                                          |          |     | True        |
| resource_group | name         | The name of the resource_group                                                                                                                                                                                  |          |     | True        |
| identity       | type         | Specifies the type of Managed Service Identity that should be configured on this API Management Service. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). |          |     | True        |
| identity       | identity_ids | A list of IDs for User Assigned Managed Identity resources to be assigned.                                                                                                                                      |          |     | False       |

## Outputs

| Name                | Description                                                                               |
| ------------------- | ----------------------------------------------------------------------------------------- | --- | --- |
| id                  | The App Configuration ID.                                                                 |     |     |
| endpoint            | The URL of the App Configuration.                                                         |     |     |
| primary_read_key    | A `primary_read_key` block as defined below containing the primary read access key.       |     |     |
| primary_write_key   | A `primary_write_key` block as defined below containing the primary write access key.     |     |     |
| secondary_read_key  | A `secondary_read_key` block as defined below containing the secondary read access key.   |     |     |
| secondary_write_key | A `secondary_write_key` block as defined below containing the secondary write access key. |     |     |
| identity            | An `identity` block as defined below.                                                     |     |     |
