# API Management email template

Manages `azurerm_api_management_email_template`. The full
[AzureRM 5.14.0 documentation](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/api_management_email_template)
was fetched through Terraform MCP and compared with the installed schema.
Not deprecated.

## Inputs and usage

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; template arguments and parent references |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key for references |
| `remote_objects` | object | `{}`; api_management and resource_groups, keyed by landing zone then resource key |

Required settings: `template_name`, `subject`, `body` (strings). `template_name`
must be an Azure predefined identifier, such as `ConfirmSignUpIdentityDefault`;
CAF naming is deliberately not applied. The body must be well-formed HTML.
APIM `$ParameterName` placeholders are passed through unchanged.
`description` and `title` are computed outputs, not configurable arguments.
All writable resource attributes and timeouts are exposed.

Parent precedence: `api_management_name`, `api_management.name`, then
`remote_objects.api_management[lz_key][key].name`. Resource group precedence:
`resource_group_name`, `resource_group.name`,
`remote_objects.resource_groups[lz_key][key].name`, then the APIM object's
`resource_group_name`. References accept `key`, optional `lz_key` defaulting to
`client_config.landingzone_key`, and direct `name`.
`timeouts` is optional and nullable: omission or explicit null omits the dynamic
block and retains AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
member values override them. Contracts cover omission, null and custom overrides,
not actual operation durations.
No child Azure tags, diagnostic settings or Private Link endpoints apply.

[Complete example](../../../examples/apim/126-api_management_email_template/configuration.tfvars)
includes its RG and APIM. Apply only this scenario's variable file.
Root/CI integration belongs to the parent task.

## Validation and lifecycle

With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_email_template -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/126-api_management_email_template/configuration.tfvars -no-color
```

Plan-only contracts mock AzureRM/CAF and assert fixed names/placeholders, local
and cross-zone parent lookup, explicit precedence and timeouts. They do not
validate actual email delivery or Azure HTML rendering. For deployment, use an
approved subscription, plan/review/apply with the example file, inspect APIM's
notification template and destroy with the same file for cleanup.

## Outputs

`id`, `template_name`, `title`, `description`, `api_management_name`,
`resource_group_name`.
