# API Management group user membership

Creates `azurerm_api_management_group_user`, matching all official AzureRM
**5.9.0** arguments and supported timeout operations.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required repository interface |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups`, `api_management`, `api_management_user`, `api_management_group` |
| `resource_group` | any | `null`; optional resolved group |
| `base_tags` | bool | `false`; association does not support Azure tags |

Required: resolvable `user_id` (**logical user identifier**), `group_name`,
`api_management_name`, `resource_group_name`. Aliases `user`, `group`,
`api_management`, `resource_group` accept key/lz_key; user accepts id, the others
accept name/id. Direct provider arguments win, then alias fields, resolved
resource group, remote `[lz_key][key]` maps. Null/omitted lz_key uses the client
landing zone. Both group and user ID-only outputs resolve their final segment.
The 5.9.0 documentation example passes a user ARM ID, but the actual provider
requires a logical identifier of at most 80 alphanumeric, underscore or dash
characters. This module accepts logical identifiers or full ARM IDs for
`user_id`/`user.id` and normalizes after choosing the highest-precedence input.

Optional `timeouts` supports **create/read/delete**, defaulting to 30m/5m/30m.
There is no update timeout, independent CAF name, location, tags, diagnostic
or private-endpoint configuration for a membership.

## Outputs and example

`id`: membership ARM ID; `user_id`: logical user identifier; `group_name`: resolved name.
See [130-api_management_group_user](../../../examples/apim/130-api_management_group_user).
The user and group must exist within the same APIM service.

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_group_user
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_group_user -no-color
```

From the root with Terraform >=1.9 and AzureRM 5.9.0. Both providers are mocked;
all commands plan. Tests assert local/remote parent resolution, ID-only group
outputs, ARM-to-logical user ID normalization, direct precedence and timeouts. Azure membership and
parent-service consistency are not proven by a mock plan.
