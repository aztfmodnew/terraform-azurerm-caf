# API Management workspace API version set

Manages `azurerm_api_management_workspace_api_version_set`. Full
[AzureRM 5.14.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/api_management_workspace_api_version_set)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated.

## Inputs and naming

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; version set arguments and workspace reference |
| `global_settings` | object | `{}`; CAF naming settings |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management_workspace |

Required strings: `name`, `display_name`, `versioning_scheme` (`Segment`,
`Header`, `Query`). Optional strings `description`, `version_header_name`,
`version_query_name` default null. Supply the matching header/query name for
those versioning schemes. All writable arguments are exposed.
Parent precedence: `api_management_workspace_id`,
`api_management_workspace.id`, then
`remote_objects.api_management_workspace[lz_key][key].id`. References accept
`id`, `key`, optional `lz_key` defaulting to `client_config.landingzone_key`.
Optional nullable `timeouts` omits its dynamic block when omitted or explicitly
null, retaining AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
values override them. Contracts cover omission/null/custom overrides, not actual
operation durations.

**CAF fallback:** the public AzureCAF `resourceDefinition.json` does not define
`azurerm_api_management_workspace_api_version_set`. This module uses the
supported `azurerm_api_management_api_version_set` definition: compatible APIM
child alphanumeric/hyphen naming and 80-character maximum, slug `apimapivs`.
No invented CAF type is passed. Global naming options remain available.
There are no Azure tag maps, child diagnostics or private endpoints.

## Example and validation

[Self-contained example](../../../examples/apim/150-api_management_workspace_api_version_set/configuration.tfvars)
creates RG, Classic Premium APIM and workspace. Review Premium quota/cost.
After parent-managed initialization:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_workspace_api_version_set -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/150-api_management_workspace_api_version_set/configuration.tfvars -no-color
```

Plan-only contracts mock AzureRM/CAF and assert local/cross-zone parents,
CAF fallback, Segment/Header/Query settings, explicit ID precedence and timeouts.
Mocks do not prove API version routing in Azure. For deployment, use an approved
subscription, plan/review/apply this single scenario, inspect the version set,
then destroy with the same file. Root/CI integration belongs to the parent.

## Outputs

`id`, `name`, `api_management_workspace_id`, `versioning_scheme`.
