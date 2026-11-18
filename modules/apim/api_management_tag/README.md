# API Management service tag

Creates `azurerm_api_management_tag` with every configurable argument and
timeout in the official AzureRM **5.9.0** docs and provider schema.
This creates a service-level label, not an Azure resource tag.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming settings |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `api_management[lz_key][key].id` |
| `base_tags` | bool | `false`; APIM label has no Azure resource tags |

Required: `name` and parent APIM ID supplied by `api_management_id`,
`api_management.id`, or `api_management = { key, lz_key? }`, in that order.
Null/omitted lz_key uses the client's landing zone.
Optional: `display_name`, `timeouts`. AzureRM defaults display_name to the
generated resource name when omitted/null; the module preserves that behavior.

CAF uses the exact public `azurerm_api_management_tag` definition.
Global prefixes/suffixes, random length, slug and passthrough apply. Use the
output **name**, not display_name, for API and product tag associations.
Timeout defaults: create/update/delete 30m, read 5m.
No fake location, Azure tags, diagnostics or private-endpoint configuration.

## Outputs and example

`id`: service tag ARM ID; `name`: generated association name;
`display_name`: human-readable display name returned by AzureRM.
See [148-api_management_tag](../../../examples/apim/148-api_management_tag).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_tag
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_tag -no-color
```

Run from the root using Terraform >=1.9, AzureRM 5.9.0 and AzureCAF. Both providers
are mocked and every run plans. Tests check local/remote/direct parent IDs,
CAF name, explicit display name, null optionals and timeouts. Provider-computed
default display names and Azure-side uniqueness are not asserted by mocks.
