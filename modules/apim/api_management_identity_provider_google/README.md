# API Management Google identity provider

Manages `azurerm_api_management_identity_provider_google`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_identity_provider_google)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated. Its fixed Azure identifier is not CAF-renamed.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; client_id, client_secret and parent references |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

`client_id` and `client_secret` are required strings. All writable resource
attributes are exposed. Optional nullable `timeouts` omits its dynamic block when
omitted or explicitly null, retaining AzureRM's create/read/update/delete defaults
30m/5m/30m/30m. Inside a supplied object, omitted/null members use these typed
defaults; explicit values override them. Contracts cover omission/null/custom
overrides, not actual operation durations.
Parent precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. RG precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then APIM object's
`resource_group_name`. References accept `key`, optional `lz_key` defaulting to
`client_config.landingzone_key`, and direct `name`.
No child Azure tags, diagnostic settings or private endpoints apply.

## Example and lifecycle

[Self-contained Azure parents example](../../../examples/apim/134-api_management_identity_provider_google/configuration.tfvars).
A Google OAuth application, consent screen and developer portal redirect URI are
prerequisites. Replace placeholders and inject the client secret securely.
Secrets are retained in Terraform state and never output; protect plans/state.

With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_identity_provider_google -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/134-api_management_identity_provider_google/configuration.tfvars -no-color
```

Mocked AzureRM/CAF plan-only contracts check client ID passthrough, local and
cross-zone parent resolution, explicit precedence and null/default/custom
timeouts. They do not test Google sign-in. Use an approved subscription,
plan/review/apply this single scenario with secure overrides, test portal login,
then destroy with the same inputs. Parent owns root and CI integration.

## Outputs

`id`, `client_id`, `api_management_name`, `resource_group_name`.
