# API Management policy fragment

Creates `azurerm_api_management_policy_fragment` using all official AzureRM
**5.14.0** arguments and timeout operations.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming settings |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `api_management[lz_key][key].id` |
| `base_tags` | bool | `false`; unused child-resource interface |

Required: `name`, `value` and parent APIM ID. Resolve the parent through direct
`api_management_id`, `api_management.id`, or alias key/lz_key, in that order.
Null/omitted landing zone uses the client's landing zone.
Optional: `format` (`xml` default, or `rawxml`), `description`, `timeouts`.
Explicit null format also defaults to xml. Match the payload to the format:
changing format changes the provider's representation of value.

CAF uses the exact public `azurerm_api_management_policy_fragment` definition.
Global naming flags, including passthrough for existing validated names, apply.
Timeouts default to 30m create/update/delete and 5m read. No unsupported child
location, Azure tags, diagnostic or private-endpoint blocks are added.

## Outputs and example

`id`: fragment ARM ID; `name`: generated name for `include-fragment`;
`format`: configured format.
See [141-api_management_policy_fragment](../../../examples/apim/141-api_management_policy_fragment).
Creating a fragment does not include it in any policy automatically.

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_policy_fragment
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_policy_fragment -no-color
```

Run from the root with Terraform >=1.9, AzureRM 5.14.0 and AzureCAF. Both providers
are mocked and runs plan. Tests assert local/remote parents, direct-ID
precedence, CAF name, XML omission/null default, rawxml, description, value and
timeouts. They do not prove fragment syntax or policy execution in APIM.
