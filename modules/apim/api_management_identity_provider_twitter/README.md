# API Management Twitter identity provider

Manages `azurerm_api_management_identity_provider_twitter`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_identity_provider_twitter)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated. Its fixed Azure identifier is deliberately not CAF-renamed.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; api_key, api_secret_key and parent references |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

`api_key` and `api_secret_key` are required strings. All writable attributes are
implemented. Optional nullable `timeouts` omits its dynamic block when omitted or
explicitly null, retaining AzureRM's create/read/update/delete defaults
30m/5m/30m/30m. Inside a supplied object, omitted/null members use these typed
defaults; explicit values override them. Contracts cover omission/null/custom
overrides, not actual operation durations.
APIM precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. RG precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then APIM object's
`resource_group_name`. References accept `key`, optional `lz_key` defaulting to
`client_config.landingzone_key`, and direct `name`.
No child Azure tag maps, diagnostics or private endpoints apply.

## Example and lifecycle

[Example with all Azure parents](../../../examples/apim/136-api_management_identity_provider_twitter/configuration.tfvars).
Prerequisites: external Twitter/X application, enabled sign-in and developer
portal callback registration. Inject both credentials securely instead of
deploying placeholders. Both are provider-sensitive and retained in state;
neither is output.

With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_identity_provider_twitter -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/136-api_management_identity_provider_twitter/configuration.tfvars -no-color
```

Mocked AzureRM/CAF plan-only contracts assert local/cross-zone lookup, explicit
name precedence and null/default/custom timeouts. They do not test Twitter/X
sign-in. In an approved subscription, plan/review/apply this scenario alone with
secure inputs, test portal login, then destroy with the same inputs.
Parent owns root and CI wiring.

## Outputs

`id`, `api_management_name`, `resource_group_name`.
