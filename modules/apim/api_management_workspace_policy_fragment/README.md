# API Management workspace policy fragment

Manages `azurerm_api_management_workspace_policy_fragment`. Full
[AzureRM 5.14.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/api_management_workspace_policy_fragment)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated.

## Inputs and naming

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; fragment arguments and workspace reference |
| `global_settings` | object | `{}`; CAF naming settings |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management_workspace |

Required strings: `name`, `xml_content`. Optional `description` defaults null;
`xml_format` accepts `xml` or `rawxml` and defaults to `xml`. All writable
provider arguments are exposed. Azure imports fragments as `xml`; update after
import when `rawxml` is desired.
Parent precedence: `api_management_workspace_id`,
`api_management_workspace.id`, then
`remote_objects.api_management_workspace[lz_key][key].id`. References accept
`id`, `key`, optional `lz_key` defaulting to `client_config.landingzone_key`.
Optional nullable `timeouts` omits its dynamic block when omitted or explicitly
null, retaining AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
values override them. `xml_format` still defaults to `xml` even when explicitly
null. Contracts cover omission/null/custom overrides, not actual operation durations.

**CAF fallback:** public AzureCAF definitions do not support
`azurerm_api_management_workspace_policy_fragment`. This module uses the
supported `azurerm_api_management_policy_fragment` type with compatible APIM
child characters, 80-character maximum and `apimpf` slug.
Global prefixes/suffixes/random_length/passthrough/use_slug are honored.
No Azure tag maps, child diagnostics or child private endpoints apply.
Avoid embedding credentials in policy XML.

## Example and validation

[Self-contained example](../../../examples/apim/154-api_management_workspace_policy_fragment/configuration.tfvars)
creates RG, Premium APIM and workspace. Review Premium quota/cost.
A fragment is reusable XML; creating it does not automatically include it in a
policy. Reference its output `name` in `include-fragment` policy elements.

With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_workspace_policy_fragment -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/154-api_management_workspace_policy_fragment/configuration.tfvars -no-color
```

AzureRM/CAF-mocked plan-only contracts assert local/cross-zone lookup, the
documented CAF fallback, both XML formats, descriptions, explicit precedence
and null/default/custom timeouts. They do not execute policy fragments in Azure.
Use an approved subscription, plan/review/apply this scenario alone, inspect the
fragment, and destroy with the same file. Root/CI integration belongs to the parent.

## Outputs

`id`, `name`, `api_management_workspace_id`, `xml_format`.
