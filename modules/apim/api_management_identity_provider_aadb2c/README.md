# API Management Azure AD B2C identity provider

Manages `azurerm_api_management_identity_provider_aadb2c`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_identity_provider_aadb2c)
were retrieved through Terraform MCP and checked against the installed schema.
Not marked deprecated by this provider version. B2C commercial availability is
separate from Terraform resource deprecation. Its fixed Azure identifier is not
CAF-renamed.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; B2C arguments and parent references |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

Required strings: `client_id`, `client_secret`, `allowed_tenant`, `authority`,
`signin_tenant`, `signin_policy`, `signup_policy`.
Optional strings: `client_library`, `password_reset_policy`,
`profile_editing_policy`, default null. All writable provider arguments are exposed.
`timeouts` is optional and nullable. Omission or an explicit null omits the
dynamic block, retaining AzureRM's create/read/update/delete defaults
30m/5m/30m/30m. Omitted/null members in a supplied object use these typed defaults;
explicit members override them. Contracts cover omission/null/custom overrides,
not actual operation durations.

Parent precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. RG precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then APIM object's
`resource_group_name`. References use `key`, optional `lz_key` defaulting to
`client_config.landingzone_key`, and optionally direct `name`.
No Azure tags, child diagnostics or child private endpoints apply.

## Example and validation

[Example with all Azure parents](../../../examples/apim/132-api_management_identity_provider_aadb2c/configuration.tfvars).
An existing B2C tenant, application, portal redirect registration and configured
user flows are prerequisites. Replace placeholder domains/IDs and inject the
client secret securely. Secrets remain in state; none are output.

With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_identity_provider_aadb2c -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/132-api_management_identity_provider_aadb2c/configuration.tfvars -no-color
```

Mocked AzureRM/CAF plan-only contracts assert local/cross-zone parent resolution,
direct precedence, required/optional B2C policies and timeouts. Live B2C login
and policy existence are not tested. Deploy only in an approved subscription:
plan/review/apply with this single scenario and secure overrides, verify portal
login, and destroy with the same inputs. Parent owns root/CI integration.

## Outputs

`id`, `allowed_tenant`, `api_management_name`, `resource_group_name`.
