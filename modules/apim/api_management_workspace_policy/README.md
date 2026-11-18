# API Management workspace policy

Manages `azurerm_api_management_workspace_policy`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_workspace_policy)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated.

## Inputs and outputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; exactly one policy source and workspace reference |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management_workspace |

`xml_content` and `xml_link` are optional strings, default null, but **exactly
one** must be supplied. The link must be publicly accessible to Azure.
All writable provider arguments are exposed.
Parent precedence: `api_management_workspace_id`,
`api_management_workspace.id`, then
`remote_objects.api_management_workspace[lz_key][key].id`. The reference accepts
`id`, `key`, optional `lz_key` defaulting to `client_config.landingzone_key`.
Optional nullable `timeouts` omits its dynamic block when omitted or explicitly
null, retaining AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
values override them. Contracts cover omission/null/custom overrides, not actual
operation durations. Policies are singletons, so CAF naming is not applicable.
No Azure tag maps, child diagnostics or private endpoints apply. Avoid embedding
credentials in XML; reference APIM secret named values instead.
Outputs: `id`, `api_management_workspace_id`.

## Example and validation

[Self-contained example](../../../examples/apim/153-api_management_workspace_policy/configuration.tfvars)
creates RG, Classic Premium APIM and workspace. Review Premium quota/cost.
It preserves policy inheritance with `<base />` elements.
With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_workspace_policy -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/153-api_management_workspace_policy/configuration.tfvars -no-color
```

AzureRM/CAF-mocked plan-only contracts check local/cross-zone workspace lookup,
inline/linked policy passthrough, explicit precedence, timeouts and both invalid
source combinations. For linked policies, the contract checks that the configured
`xml_content` input is null; the optional+computed resource attribute can remain
unknown during planning. Mocks do not execute policies or fetch linked documents.
Use an approved subscription: plan/review/apply this single scenario, test gateway
behavior, then destroy with the same file. Root/CI integration belongs to the
parent task.
