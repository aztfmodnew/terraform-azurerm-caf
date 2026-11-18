# API Management global schema

Creates `azurerm_api_management_global_schema` with the full official AzureRM
**5.9.0** arguments and timeout contract.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups` and `api_management` |
| `resource_group` | any | `null`; optional resolved group |
| `base_tags` | bool | `false`; unused by this child |

Required: `schema_id`, `type` (`xml` or `json`), `value`, and resolvable
`api_management_name` / `resource_group_name`. Optional: `description`, `timeouts`.
Parent aliases `api_management` and `resource_group` accept name, ARM id, or
key/lz_key. Direct names win, then alias fields, resolved group, remote maps.
Maps use `[lz_key][key]`, defaulting null/omitted lz_key to the client landing zone.
Values are passed as strings without modifying the schema contents.

Exact public CAF type: `azurerm_api_management_global_schema`.
Global passthrough can preserve a validated identifier. Timeout defaults:
create/update/delete 30m, read 5m. There are no fake child location, Azure tags,
diagnostic or private-endpoint blocks.

## Outputs and example

`id`: schema ARM ID; `schema_id`: generated short identifier; `type`: content type.
See [129-api_management_global_schema](../../../examples/apim/129-api_management_global_schema).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_global_schema
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_global_schema -no-color
```

Run from the root using Terraform >=1.9, AzureRM 5.9.0 and AzureCAF. Both
providers are mocked for plan-only assertions of CAF naming, local/remote
parents, direct precedence, XML/JSON values, description, nulls and timeouts.
Schema acceptance and policy validation in Azure are not established.
