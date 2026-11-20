# API Management Microsoft identity provider

Manages `azurerm_api_management_identity_provider_microsoft`. Full
[AzureRM 5.14.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/api_management_identity_provider_microsoft)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated. Its Azure provider identifier is fixed; no CAF naming is applied.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; client_id, client_secret and parent references |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

`client_id` and `client_secret` are required strings. All writable provider
arguments are exposed. Optional nullable `timeouts` omits its dynamic block when
omitted or explicitly null, retaining AzureRM's create/read/update/delete defaults
30m/5m/30m/30m. Inside a supplied object, omitted/null members use these typed
defaults; explicit values override them. Contracts cover omission/null/custom
overrides, not actual operation durations.
APIM name precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. RG precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then APIM object's
`resource_group_name`. Reference objects accept `key`, optional `lz_key` defaulting
to `client_config.landingzone_key`, and direct `name`.
No Azure resource tags, diagnostics or private endpoints apply to this child.

## Example and validation

[Complete Azure parents example](../../../examples/apim/135-api_management_identity_provider_microsoft/configuration.tfvars).
Prerequisites: an application registered for the desired Microsoft sign-in
audience and the developer portal redirect URI. Replace example IDs and inject a
client secret securely. Secrets remain in state; none are output.

After parent-managed initialization:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_identity_provider_microsoft -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/135-api_management_identity_provider_microsoft/configuration.tfvars -no-color
```

Plan-only contracts mock AzureRM/CAF and assert client ID passthrough,
local/cross-zone resolution, explicit precedence and null/default/custom timeouts.
They do not verify live login. Select an approved subscription, plan/review/apply
this single scenario with secure overrides, verify portal login, then destroy
with the same inputs. Root and CI wiring belong to the parent.

## Outputs

`id`, `client_id`, `api_management_name`, `resource_group_name`.
