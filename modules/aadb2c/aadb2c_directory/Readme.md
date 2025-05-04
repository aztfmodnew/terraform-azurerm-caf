module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.26.1"
}

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_aadb2c_directory.aadb2c](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/aadb2c_directory) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_tags"></a> [base\_tags](#input\_base\_tags) | Base tags for the resource to be inherited from the resource group. | `bool` | n/a | yes |
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | Global settings object (see module documentation for details). | `any` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group object of the Resource Group where the AAD B2C Directory should exist. Changing this forces a new AAD B2C Directory to be created. | `any` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group where the AAD B2C Directory should exist. Changing this forces a new AAD B2C Directory to be created. | `string` | `null` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Settings object for the Azure B2C Tenant. This is a map of settings that will be used to create the Azure B2C Tenant.<br/>    The settings are:<br/>      - country\_code - (Optional) Country code of the B2C tenant. The country\_code should be valid for the specified data\_residency\_location. See official docs for valid country codes. Required when creating a new resource. Changing this forces a new AAD B2C Directory to be created.<br/>      - data\_residency\_location - (Required) Location in which the B2C tenant is hosted and data resides. The data\_residency\_location should be valid for the specified country\_code. See official docs for more information. Changing this forces a new AAD B2C Directory to be created. Possible values are Asia Pacific, Australia, Europe, Global and United States.<br/>      - display\_name - (Optional) The initial display name of the B2C tenant. Required when creating a new resource. Changing this forces a new AAD B2C Directory to be created.<br/>      - domain\_name - (Required) Domain name of the B2C tenant, including the .onmicrosoft.com suffix. Changing this forces a new AAD B2C Directory to be created.<br/>      - sku\_name - (Required) Billing SKU for the B2C tenant. Must be one of: PremiumP1 or PremiumP2 (Standard is not supported). See official docs for more information.<br/>      - tags - (Optional) A mapping of tags which should be assigned to the AAD B2C Directory. | <pre>object({<br/>    country_code            = optional(string)      # Marked as optional<br/>    data_residency_location = string                # Required<br/>    display_name            = optional(string)      # Marked as optional<br/>    domain_name             = string                # Required<br/>    sku_name                = string                # Required<br/>    tags                    = optional(map(string)) # Marked as optional<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | n/a |
