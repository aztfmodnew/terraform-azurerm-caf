# API Management service policy

Manages the **service-wide** `azurerm_api_management_policy` with every official
AzureRM **5.14.0** argument. This is not a product/API/operation policy.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required repository interface |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `api_management[lz_key][key].id` |
| `base_tags` | bool | `false`; service policy has no Azure tags |

Required parent: `api_management_id`, `api_management.id`, or
`api_management = { key, lz_key? }`. Direct ID wins, then alias ID, then lookup;
omitted/null landing zone uses the client landing zone.
Supply exactly one of `xml_content` (inline policy XML) and `xml_link`
(publicly accessible policy XML URL). Both/neither fail input validation.
Optional `timeouts`: create/update/delete default 30m, read defaults 5m.

Only one global policy can exist per service. Do not manage it simultaneously
from an embedded parent configuration, another module or another state.
Import or migrate existing ownership deliberately before applying.
There is no independent name, child location, tags, diagnostics or private
endpoint block. Child modules for those capabilities are not fabricated.

## Outputs and example

`id`: service policy ARM ID; `api_management_id`: resolved parent service ID.
See [140-api_management_policy](../../../examples/apim/140-api_management_policy).
Review the entire policy before deploying: it affects every API in the service.

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_policy
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_policy -no-color
```

From the root, use Terraform >=1.9 and AzureRM 5.14.0. Both providers are mocked
and all runs plan. Assertions cover inline/linked policies, local/remote parent
IDs, direct precedence, null link, timeouts and each source-validation failure.
Policy execution, URL availability and effects on live APIs remain unverified.
