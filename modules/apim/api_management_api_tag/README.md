# API Management API tag association

Associates an **existing service tag** with an API using
`azurerm_api_management_api_tag` (official AzureRM **5.9.0** docs/schema).
It does not create or rename a service tag.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required repository interface; no naming here |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed fields](variables.tf) |
| `remote_objects` | any | `{}`; `api_management_api` and `api_management_tag` |
| `base_tags` | bool | `false`; unused, association has no Azure tags |

Required dependencies: API ARM ID via `api_id`, `api.id`, or `api.key`; existing
tag name via `name`, `tag.name`, `tag.id`, or `tag.key`. Objects also accept
`lz_key`. Explicit provider arguments win over alias fields and remote lookups.
Remote maps are `[lz_key][key]`; omitted/null landing zone uses the client
landing zone. An ID-only tag output resolves its final segment as the name.
Do not pass a tag display label in place of its actual name.

The public AzureCAF naming definition contains the corresponding resource type,
but this is an association: re-generating the existing tag name would be wrong.
No naming resource, location, tags, diagnostics or private endpoints are created.
Optional `timeouts` supports **create/read/delete only** (30m/5m/30m defaults).

## Outputs and example

`id` is the API tag association ARM ID, suitable for `api_tag_description`.
`name` is the unchanged tag name; `api_id` is the resolved parent ARM ID.
See [122-api_management_api_tag](../../../examples/apim/122-api_management_api_tag).

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_tag
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_tag -no-color
```

From the root, use Terraform >=1.9 and AzureRM 5.9.0; both AzureRM and AzureCAF
are mocked. Plan assertions cover local/remote references, ID-only tag outputs,
direct-argument precedence, unchanged names and immutable timeouts. They do not
prove that a tag exists in Azure or belongs to the API's APIM service.
