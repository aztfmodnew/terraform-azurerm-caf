# API Management Facebook identity provider

Manages `azurerm_api_management_identity_provider_facebook`. Full
[AzureRM 5.14.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/api_management_identity_provider_facebook)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated. The provider has a fixed Azure identifier and is not CAF-renamed.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; app_id, app_secret and parent references |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

`app_id` and `app_secret` are required strings. All writable attributes are
implemented. Optional nullable `timeouts` omits its dynamic block when omitted or
explicitly null, retaining AzureRM's create/read/update/delete defaults
30m/5m/30m/30m. Inside a supplied object, omitted/null members use these typed
defaults; explicit values override them. Contracts cover omission/null/custom
overrides, not actual operation durations.

APIM name precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. RG precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then APIM object's
`resource_group_name`. Both reference objects accept `key`, optional `lz_key`
defaulting to `client_config.landingzone_key`, and direct `name`.
No Azure tag maps, diagnostics or private endpoints apply to this child.

## Example, validation and lifecycle

[Complete Azure parents example](../../../examples/apim/133-api_management_identity_provider_facebook/configuration.tfvars).
Prerequisites: Facebook application, developer portal redirect registration,
and its secret supplied securely. Replace placeholders before deploying; secrets
are provider-sensitive but retained in state and are never output.

After parent-managed initialization:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_identity_provider_facebook -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/133-api_management_identity_provider_facebook/configuration.tfvars -no-color
```

Plan-only contracts mock AzureRM/CAF and check application ID passthrough,
local/cross-zone parents, direct precedence and default/null/custom timeouts.
They do not test Facebook connectivity. Select an approved subscription,
plan/review/apply this scenario alone with secure overrides, verify portal login
and destroy with the same inputs. Parent owns root and CI integration.

## Outputs

`id`, `app_id`, `api_management_name`, `resource_group_name`.
