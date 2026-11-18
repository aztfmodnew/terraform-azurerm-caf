# API Management authorization server

Manages `azurerm_api_management_authorization_server`. Validated against the full
[AzureRM 5.9.0 documentation](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_authorization_server)
through Terraform MCP and the installed exact provider schema. Not deprecated.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; arguments below |
| `global_settings` | object | `{}`; CAF prefixes, suffixes, random_length, passthrough, use_slug |
| `client_config` | object | `{}`; landingzone_key for key references |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and resource_groups |

Required settings: `name`, `display_name`, `authorization_endpoint`,
`authorization_methods` (set of HTTP verbs including GET), `client_id`,
`client_registration_endpoint`, `grant_types` (set of grant names).
Optional settings, default null: `bearer_token_sending_methods`,
`client_authentication_method` (sets of strings), `client_secret`, `default_scope`,
`description`, `resource_owner_password`, `resource_owner_username`,
`support_state` (bool), `token_endpoint`.
`token_body_parameter` defaults to `[]` and accepts a list of objects with required
string `name` and `value`. Resource owner credentials require the
`resourceOwnerPassword` grant. All provider attributes and nested blocks are exposed;
computed `id` is output-only.

Parent precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. Resource group precedence:
`resource_group_name`, `resource_group.name`, the
`remote_objects.resource_groups[lz_key][key].name` reference, then the resolved
APIM object's `resource_group_name`. Both reference objects accept `key` and
optional `lz_key` (defaults to `client_config.landingzone_key`).

`timeouts` is optional and nullable. Omission or an explicit null omits the
dynamic block, leaving AzureRM's 30m/5m/30m/30m create/read/update/delete defaults
in control. Within a supplied object, omitted/null members use those same typed
defaults; explicit member values override them.
CAF uses the supported `azurerm_api_management_authorization_server` type.
No Azure tag maps, diagnostics or private endpoints apply to this child resource;
configure monitoring/network access on the parent APIM service.
Inject secrets securely and protect Terraform state; secrets are never output.

## Usage and validation

[Self-contained example](../../../examples/apim/125-api_management_authorization_server/configuration.tfvars)
creates its resource group and APIM parent. Replace example OAuth registration
details before deployment. Load this scenario alone, not alongside other complete
scenarios. Root integration and CI registration are maintained by the parent task.

After the parent has initialized the examples configuration:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_authorization_server -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/125-api_management_authorization_server/configuration.tfvars -no-color
```

Contracts mock AzureRM and CAF and use plan-only commands. They assert local and
cross-zone resolution, direct precedence, CAF names, nested token parameters and
timeouts, including omission, explicit null and custom overrides. They do not
prove OAuth connectivity, actual timeout durations or Azure service acceptance.
For deployment, authenticate to an approved subscription, plan with this single
variable file, review before apply, inspect the authorization server in APIM and
destroy with the same file when finished.

## Outputs

`id`, `name`, `display_name`, `api_management_name`, `resource_group_name`.
