# API Management OpenID Connect provider

Manages `azurerm_api_management_openid_connect_provider`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_openid_connect_provider)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; provider arguments and parent references |
| `global_settings` | object | `{}`; CAF naming settings |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

Required strings: `name`, `display_name`, `client_id`, `client_secret`,
`metadata_endpoint`. Optional string `description` defaults to null.
All writable resource attributes are exposed; computed `id` is output-only.
CAF uses the supported `azurerm_api_management_openid_connect_provider` type,
with global prefixes/suffixes/random_length/passthrough/use_slug.

APIM name precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. RG precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then APIM object's
`resource_group_name`. References accept `key`, optional `lz_key` defaulting to
`client_config.landingzone_key`, and direct `name`.
Optional nullable `timeouts` omits its dynamic block when omitted or explicitly
null, retaining AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
values override them. Contracts cover omission/null/custom overrides, not actual
operation durations. No child Azure tags, diagnostics or private endpoints apply.

## Example and lifecycle

[Self-contained Azure parents example](../../../examples/apim/139-api_management_openid_connect_provider/configuration.tfvars).
Prerequisites: an OpenID Connect application registration, reachable discovery
endpoint and correct APIM redirect configuration. Replace example IDs/URI and
inject the secret securely. Both client fields are provider-sensitive; protect
state and plans. No credential outputs are exposed.

With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_openid_connect_provider -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/139-api_management_openid_connect_provider/configuration.tfvars -no-color
```

Plan-only contracts mock AzureRM/CAF and check local/cross-zone parents,
CAF name/metadata passthrough, description, direct precedence and timeouts.
They do not validate discovery or live authentication. In an approved
subscription, plan/review/apply this scenario alone with secure overrides,
verify the provider in APIM and destroy with the same inputs.
Parent owns root and CI integration.

## Outputs

`id`, `name`, `metadata_endpoint`, `api_management_name`, `resource_group_name`.
