# API Management API schema

Creates `azurerm_api_management_api_schema`; all configurable arguments and
timeouts follow the official AzureRM **5.14.0** documentation and local schema.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming settings |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; see [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups`, `api_management`, `api_management_api` |
| `resource_group` | any | `null`; optional resolved group object |
| `base_tags` | bool | `false`; unused child-resource interface |

Required settings: `schema_id`, `content_type`, and resolvable `api_name`,
`api_management_name`, `resource_group_name`. Optional payloads are `value`,
`components` (Swagger/OpenAPI v2/v3), `definitions` (v1), and `timeouts`.
Although individually optional, exactly one payload field must be non-null.
The installed provider enforces this exclusivity even though the documentation
lists the fields independently.
Payload strings are passed unchanged: choose fields appropriate to the content
type rather than treating the three payload fields as interchangeable.

Parent aliases `api`, `api_management`, `resource_group` accept `name`, ARM `id`,
or `{ key, lz_key? }`. Direct provider names win, then alias name/id, optional
resolved group, then remote lookup. Remote objects use `[lz_key][key]`;
omitted/null landing zone uses `client_config.landingzone_key`. API/APIM names
fall back to the last segment of ID-only parent outputs.

Exact CAF type: `azurerm_api_management_api_schema`, checked in public AzureCAF
`resourceDefinition.json`. The generated value is exposed as `schema_id`.
`global_settings.passthrough = true` preserves an existing validated identifier.
Timeouts create/update/delete default to 30m and read to 5m. No Azure resource
tags, location or unsupported child diagnostic/private-endpoint blocks are added.

## Outputs and example

Outputs: `id` (schema ARM ID), `schema_id` (short generated identifier),
`api_name` (resolved API).
See [121-api_management_api_schema](../../../examples/apim/121-api_management_api_schema).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_schema
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_schema -no-color
```

Run from the root with Terraform >=1.9, AzureRM 5.14.0 and AzureCAF installed.
Both providers are mocked; command is plan. Assertions cover CAF schema IDs,
local/remote and ID-only parents, direct-name precedence, all payload fields,
nulls and timeouts. Schema parsing by APIM itself remains unverified.
