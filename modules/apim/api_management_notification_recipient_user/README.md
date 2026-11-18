# API Management notification user recipient

Manages `azurerm_api_management_notification_recipient_user`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_notification_recipient_user)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated.

## Inputs and outputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; notification_type and APIM/user references |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management and api_management_users |

Required `notification_type` is a string; valid values are
`AccountClosedPublisher`, `BCC`, `NewApplicationNotificationMessage`,
`NewIssuePublisherNotificationMessage`, `PurchasePublisherNotificationMessage`,
`QuotaLimitApproachingPublisherNotificationMessage`,
`RequestPublisherNotificationMessage`. All provider arguments are exposed.

APIM precedence: `api_management_id`, `api_management.id`,
`remote_objects.api_management[lz_key][key].id`.
User precedence: `user_id`, `user.user_id`, then
`remote_objects.api_management_users[lz_key][key].user_id`. Existing CAF user
outputs exposing only `id` are supported by extracting the last ARM ID segment.
The resource needs the **APIM-local user identifier, not the full ARM ID**.
Both references accept `key` and optional `lz_key`, defaulting to
`client_config.landingzone_key`; the user must belong to the selected APIM.

Optional nullable `timeouts` has create/read/delete only. Omission/null omits its
dynamic block, retaining AzureRM's 30m/5m/30m defaults. Inside a supplied object,
omitted/null members use these typed defaults; explicit values override them.
Contracts cover omission/null/custom overrides, not actual operation durations.
There is no update timeout. No CAF name, Azure tags, child diagnostics
or private endpoints apply.
Outputs: `id`, `api_management_id`, `user_id`, `notification_type`.

## Example and tests

[Complete example](../../../examples/apim/138-api_management_notification_recipient_user/configuration.tfvars)
creates its RG, APIM and recipient user. Replace example email addresses.
With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_notification_recipient_user -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/138-api_management_notification_recipient_user/configuration.tfvars -no-color
```

AzureRM/CAF-mocked plan-only contracts assert local/cross-zone dependencies,
legacy user ARM ID extraction, direct precedence and supported timeouts.
They do not test notification delivery or user ownership in Azure.
For deployment, select an approved subscription, plan/review/apply this single
scenario, inspect recipients and destroy with the same file for cleanup.
Root/CI integration belongs to the parent.
