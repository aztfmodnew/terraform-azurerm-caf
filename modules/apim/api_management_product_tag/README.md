# API Management product tag association

Creates `azurerm_api_management_product_tag` with the full official AzureRM
**5.9.0** argument and timeout surface. It links an existing service tag.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required interface; existing names are not renamed |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups`, `api_management`, `api_management_product`, `api_management_tag` |
| `resource_group` | any | `null`; optional resolved group |
| `base_tags` | bool | `false`; unused by this association |

Required: resolvable `api_management_product_id`, `name` (existing tag name),
`api_management_name`, `resource_group_name`. Aliases `product`, `tag`,
`api_management`, `resource_group` accept name, ARM id, or key/lz_key. Product
also accepts `product_id`. Explicit provider arguments win over alias fields,
then resolved group, then remote `[lz_key][key]`. Null/omitted lz_key uses the
client landing zone.

Despite its name, `api_management_product_id` is the **short product identifier**,
not the ARM ID. Full ARM IDs supplied in `product.id` or ID-only remote outputs
resolve their final segment. Tags resolve their actual name, not display_name.
No new CAF tag name is generated for an existing tag association.

Optional `timeouts`: **create/read/delete**, defaults 30m/5m/30m.
No location, Azure tags, diagnostics or private endpoints are fabricated.
Do not manage the same association from two modules/states.

## Outputs and example

`id`: association ARM ID; `name`: existing tag name;
`api_management_product_id`: short product ID.
See [145-api_management_product_tag](../../../examples/apim/145-api_management_product_tag).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_product_tag
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_product_tag -no-color
```

From the root with Terraform >=1.9 and AzureRM 5.9.0. Both providers are mocked
for plan-only assertions of local/remote and ID-only parents, existing tag
names, short product IDs, direct precedence and timeouts. Existence and parent
service consistency are not verified in Azure.
