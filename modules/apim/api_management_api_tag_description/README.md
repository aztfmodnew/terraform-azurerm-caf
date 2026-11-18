# API Management API tag description

Creates `azurerm_api_management_api_tag_description` with the complete official
AzureRM **5.9.0** configuration surface.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required repository interface |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `api_management_api_tag[lz_key][key].id` |
| `base_tags` | bool | `false`; unused by this child resource |

Required dependency: `api_tag_id`, `api_tag.id`, or `api_tag = { key, lz_key? }`.
This must be the **API-level tag association** ARM ID, not a service-level tag.
Direct ID wins over alias ID, then remote lookup. Omitted/null `lz_key` uses
`client_config.landingzone_key`.

All optional settings are exposed: `description`, `external_documentation_url`,
`external_documentation_description`, and create/read/update/delete `timeouts`.
Default timeouts are 30m/5m/30m/30m, delegated to AzureRM when omitted.
There is no independently named resource, location, Azure tags or child
diagnostic/private-endpoint configuration.

## Outputs and example

`id`: description resource ARM ID; `api_tag_id`: resolved API tag association.
See [123-api_management_api_tag_description](../../../examples/apim/123-api_management_api_tag_description).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_tag_description
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_tag_description -no-color
```

Run from the root with Terraform >=1.9 and AzureRM 5.9.0. Both providers are
mocked and every run is plan-only. Assertions cover local/remote association
IDs, direct-ID precedence, all documentation fields, explicit nulls and
timeouts. They do not verify external URLs or Azure-side tag ownership.
