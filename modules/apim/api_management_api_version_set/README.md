# API Management API version set

Creates `azurerm_api_management_api_version_set`, implementing the full official
AzureRM **5.9.0** arguments, outputs and timeout surface.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming settings |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups` and `api_management` |
| `resource_group` | any | `null`; optional resolved group |
| `base_tags` | bool | `false`; child does not support Azure tags |

Required: `name`, `display_name`, `versioning_scheme`, and resolvable parent
APIM/resource-group names. Schemes are `Segment`, `Header`, `Query`. `Header`
requires `version_header_name`; `Query` requires `version_query_name`.
Optional: both version-name fields, `description`, and `timeouts`.

Supply direct `api_management_name` / `resource_group_name`, or parent aliases
`api_management` / `resource_group` accepting name, ARM id, or key with optional
lz_key. Direct arguments win, then alias name/id, resolved group, remote maps.
Maps use `[lz_key][key]`, defaulting null/omitted lz_key to the client landing zone.

CAF uses the exact public `azurerm_api_management_api_version_set` definition.
Set global passthrough to preserve an existing validated name. Create/update/
delete timeout defaults are 30m; read is 5m. No fake child location, tags,
diagnostic or private-endpoint blocks are present.

## Outputs and example

`id` is suitable for an API's `version_set_id`; `name` is the generated name;
`display_name` is the human-readable label.
See [124-api_management_api_version_set](../../../examples/apim/124-api_management_api_version_set).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_version_set
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_version_set -no-color
```

Requires Terraform >=1.9, AzureRM 5.9.0 and AzureCAF. Both providers are mocked
for plan-only tests. Contracts check all three schemes, local/remote parents,
direct precedence, optional fields/timeouts and each validation independently.
Mock plans do not establish Azure API routing behavior.
