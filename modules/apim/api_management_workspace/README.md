# API Management workspace

Manages `azurerm_api_management_workspace`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_workspace)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated. This provider version documents **Classic Premium SKU** support.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; workspace arguments and APIM reference |
| `global_settings` | object | `{}`; CAF naming settings |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management |

Required strings: `name`, `display_name`. Optional `description` defaults to
null. All writable provider arguments are exposed.
Parent ID precedence: `api_management_id`, `api_management.id`, then
`remote_objects.api_management[lz_key][key].id`. The `api_management` reference
accepts `id`, `key`, optional `lz_key` defaulting to
`client_config.landingzone_key`.
Optional nullable `timeouts` omits its dynamic block when omitted or explicitly
null, retaining AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
values override them. Contracts cover omission/null/custom overrides, not actual
operation durations.

CAF uses the public, supported `azurerm_api_management_workspace` definition.
Global prefixes/suffixes/random_length/passthrough/use_slug are honored.
No Azure tag maps or standalone diagnostic/private endpoint resources are added
at workspace scope; configure service networking/monitoring on the APIM parent.

## Example, validation and lifecycle

[Complete Premium APIM example](../../../examples/apim/149-api_management_workspace/configuration.tfvars).
Prerequisites: subscription permissions, Premium capacity/quota and budget.
Premium APIM is chargeable; review costs before applying.
With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_workspace -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/149-api_management_workspace/configuration.tfvars -no-color
```

AzureRM/CAF-mocked plan-only contracts assert local/cross-zone APIM lookup, the
supported CAF type, display name/description, direct precedence and typed
timeouts. They do not prove SKU availability or service-side behavior.
Deploy only in an approved subscription: plan/review/apply this single scenario,
inspect APIM workspaces, then destroy with the same file.
Root and CI integration belong to the parent task.

## Outputs

`id`, `name`, `api_management_id`, `display_name`. The ID is suitable for the
`remote_objects.api_management_workspace[lz_key][key]` collection passed to child
modules.
