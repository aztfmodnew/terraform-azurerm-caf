# API Management AAD identity provider

Manages `azurerm_api_management_identity_provider_aad` (Microsoft Entra ID).
Full [AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_identity_provider_aad)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated. Azure's fixed `aad` provider identifier is not CAF-renamed.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; required/optional settings below |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

Required settings: `client_id`, `client_secret` (strings), `allowed_tenants`
(list of strings). Optional strings `client_library` and `signin_tenant`
default to null (provider behavior). When supplied, `signin_tenant` must be a
tenant UUID, not an `onmicrosoft.com` domain. All writable provider arguments are exposed.
`timeouts` is optional and nullable. Omitted or explicitly null objects omit the
dynamic block, retaining AzureRM's create/read/update/delete defaults
30m/5m/30m/30m. Omitted/null members inside a supplied object use these typed
defaults; explicit members override them. Contracts cover omission/null/custom
overrides, not actual operation durations.

Parent name precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. RG precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then APIM object's
`resource_group_name`. Reference `lz_key` defaults to
`client_config.landingzone_key`; `key` selects the parent.
This child has no Azure tags, diagnostics or private endpoints; use parent APIM.

## Example and tests

[Self-contained Azure parents example](../../../examples/apim/131-api_management_identity_provider_aad/configuration.tfvars).
Prerequisites: an Entra application, correct developer portal redirect URI,
tenant consent, and a client secret injected through an untracked secure input.
Do not deploy the example placeholders. Secrets are provider-sensitive, retained
in state and not output; protect state and plan files.

After parent-managed initialization:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_identity_provider_aad -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/131-api_management_identity_provider_aad/configuration.tfvars -no-color
```

Contracts mock AzureRM/CAF and plan only: local/cross-zone parents, direct-name
precedence, optional tenant/library passthrough and timeout defaults/overrides.
No live Entra login is tested. For deployment, select an approved subscription,
plan/review/apply this single example file with secure overrides, test portal
login, then destroy with the same inputs. Root and CI wiring belong to the parent.

## Outputs

`id`, `allowed_tenants`, `api_management_name`, `resource_group_name`.
