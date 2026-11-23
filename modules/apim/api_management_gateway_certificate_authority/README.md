# API Management gateway certificate authority

Creates `azurerm_api_management_gateway_certificate_authority` using all
arguments in the official AzureRM **5.14.0** docs and provider schema.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required repository interface; no new name |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `api_management`, `api_management_gateway`, `api_management_certificate` |
| `base_tags` | bool | `false`; unused by this association |

Required parent arguments: `api_management_id`, `gateway_name`,
`certificate_name`, or corresponding `api_management`, `gateway`, `certificate`
aliases. APIM accepts id or key/lz_key; gateway/certificate additionally accept
name and extract names from ARM IDs. Existing repository modules exposing only
id are supported. Direct arguments win, then alias fields, then remote maps
`[lz_key][key]`; absent/null lz_key uses the client landing zone.

Optional: `is_trusted` and create/read/update/delete `timeouts`.
No trust default is invented: null is delegated to the provider.
Timeout defaults are 30m/5m/30m/30m. This association has no independent CAF
name, location, tags, diagnostic or private-endpoint blocks.

## Outputs and example

`id`: association ARM ID; `gateway_name`, `certificate_name`: resolved names.
See [127-api_management_gateway_certificate_authority](../../../examples/apim/127-api_management_gateway_certificate_authority).
The certificate must already exist in the same service as the gateway.

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_gateway_certificate_authority
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_gateway_certificate_authority -no-color
```

Run from the root with Terraform >=1.9 and AzureRM 5.14.0. Both providers are
mocked, all runs use plan. Assertions cover ID-only local/remote parent outputs,
direct precedence, true/false trust and timeouts. No certificate bytes are
loaded; actual gateway trust and certificate suitability remain unverified.
