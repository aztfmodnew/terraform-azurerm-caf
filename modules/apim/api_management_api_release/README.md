# API Management API release

Creates `azurerm_api_management_api_release`, validated against the official
AzureRM **5.14.0** documentation and installed schema. Publishing a release can
change the current API revision; review the target revision before deployment.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming configuration |
| `client_config` | any | Required; `landingzone_key` for key references |
| `settings` | object | Required; typed in [variables.tf](variables.tf) |
| `remote_objects` | any | `{}`; `api_management_api[lz_key][key].id` |
| `base_tags` | bool | `false`; repository interface, not used by AzureRM |

Settings: required `name`; required API supplied by `api_id`, `api.id`, or
`api = { key, lz_key? }`; optional `notes`, `timeouts`.
Direct ID wins over the reference ID, then remote lookup. Omitted/null `lz_key`
uses the current landing zone. Use an API revision ARM ID, including `;rev=N`.

The exact CAF type `azurerm_api_management_api_release` is present in public
[`resourceDefinition.json`](https://github.com/aztfmodnew/terraform-provider-azurecaf/blob/main/resourceDefinition.json).
Global prefixes/suffixes, random length, slug and passthrough are supported.
Timeouts: create/update/delete default to 30m, read to 5m; all are overridable.
This child has no location, Azure tags, diagnostic or private-endpoint blocks.

## Outputs and usage

`id`: release ARM ID; `name`: generated name; `api_id`: resolved API revision ID.
Use [120-api_management_api_release](../../../examples/apim/120-api_management_api_release)
for a complete root configuration creating APIM, an API revision and its release.
When calling directly, pass the five inputs above; no root integration is
performed by this child module.

## Mock contract

From the repository root:

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_release
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_release -no-color
```

Requires Terraform >=1.9 for plan-time mocks, AzureRM 5.14.0 and AzureCAF.
The plan-only contract checks local/remote API references, direct-ID
precedence, CAF name, notes, null optionals and timeouts. Both providers are
mocked. It does not publish an API revision or prove Azure-side acceptance.
