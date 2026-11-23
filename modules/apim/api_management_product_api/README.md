# API Management product API association

Creates `azurerm_api_management_product_api`; every configurable argument and
timeout matches the official AzureRM **5.14.0** documentation/schema.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required repository interface |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups`, `api_management`, `api_management_api`, `api_management_product` |
| `resource_group` | any | `null`; optional resolved group |
| `base_tags` | bool | `false`; unused by this association |

Required: resolvable `api_name`, `product_id`, `api_management_name`,
`resource_group_name`. Direct provider arguments win over aliases `api`,
`product`, `api_management`, `resource_group`, then remote lookup.
Aliases accept name, ARM id or key/lz_key; product additionally accepts
`product_id`. Remote maps use `[lz_key][key]`, defaulting null/omitted lz_key
to the client landing zone.

`settings.product_id` must be a **short product identifier**. A full ARM ID can
instead be supplied as `product.id`; its final segment is used. Remote product
objects prefer `product_id`, falling back to the last segment of id. API names
also support ID-only outputs.

Optional `timeouts`: **create/read/delete only**, defaults 30m/5m/30m.
No independent CAF name, location, tags, diagnostics or private endpoints.
Do not duplicate a product/API association managed by an embedded parent list.

## Outputs and example

`id`: association ARM ID; `product_id`: short product ID; `api_name`: API name.
See [142-api_management_product_api](../../../examples/apim/142-api_management_product_api).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_product_api
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_product_api -no-color
```

Run from the root using Terraform >=1.9 and AzureRM 5.14.0. Both providers are
mocked; plan assertions cover local/remote parents, ID-only fallbacks, short-ID
semantics, direct precedence and timeouts. Azure product/API ownership and
authorization are not verified.
