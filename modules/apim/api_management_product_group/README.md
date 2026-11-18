# API Management product group association

Creates `azurerm_api_management_product_group`, matching the official AzureRM
**5.9.0** arguments and supported timeout operations.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required repository interface |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups`, `api_management`, `api_management_product`, `api_management_group` |
| `resource_group` | any | `null`; optional resolved group |
| `base_tags` | bool | `false`; unused by this association |

Required: resolvable `product_id`, `group_name`, `api_management_name`,
`resource_group_name`. Parent aliases are `product`, `group`, `api_management`,
`resource_group`; they accept name, ARM id or key/lz_key. Product also accepts
`product_id`. Precedence is direct provider argument, explicit alias field,
resolved resource group, remote `[lz_key][key]`. Null/omitted lz_key defaults to
the current client landing zone.

`settings.product_id` is the **short product identifier**, not its ARM ID.
Supply a full ARM ID via `product.id` if needed. ID-only remote product/group
outputs are converted to short product ID/group name. A remote product's
`product_id` is preferred when present.

Optional `timeouts`: **create/read/delete**, defaults 30m/5m/30m. This
association has no CAF-generated name, location, tags, diagnostics or private
endpoint blocks. Do not duplicate an association already owned elsewhere.

## Outputs and example

`id`: association ARM ID; `product_id`: short product ID; `group_name`: group name.
See [143-api_management_product_group](../../../examples/apim/143-api_management_product_group).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_product_group
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_product_group -no-color
```

Run from the root using Terraform >=1.9 and AzureRM 5.9.0. Both providers are
mocked and commands plan. Contracts cover local/remote and ID-only parents,
direct precedence, short product IDs and immutable timeouts. Azure access
control and same-service parent validation are not established.
