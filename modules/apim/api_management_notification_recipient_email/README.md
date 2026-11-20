# API Management notification email recipient

Manages `azurerm_api_management_notification_recipient_email`. Full
[AzureRM 5.14.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/api_management_notification_recipient_email)
were fetched through Terraform MCP and compared with the installed schema.
Not deprecated.

## Inputs and outputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; email, notification_type and APIM reference |
| `global_settings` | object | `{}`; reserved |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management |

Required strings: `email`, `notification_type`. All writable provider arguments
are exposed. Notification types are `AccountClosedPublisher`, `BCC`,
`NewApplicationNotificationMessage`, `NewIssuePublisherNotificationMessage`,
`PurchasePublisherNotificationMessage`,
`QuotaLimitApproachingPublisherNotificationMessage`,
`RequestPublisherNotificationMessage`.

Parent ID precedence: `api_management_id`, `api_management.id`, then
`remote_objects.api_management[lz_key][key].id`. The `api_management` object
accepts `id`, `key`, optional `lz_key` defaulting to
`client_config.landingzone_key`. Optional nullable `timeouts` supports **only
create/read/delete**. Omission/null omits the dynamic block, retaining AzureRM's
30m/5m/30m defaults. In a supplied object, omitted/null members use these typed
defaults; explicit values override them. Contracts cover omission/null/custom
overrides, not actual operation durations. The resource has no update operation.
No CAF name, Azure tags, child diagnostics or child private endpoints
apply.

Outputs: `id`, `api_management_id`, `email`, `notification_type`.

## Example and validation

[Self-contained example](../../../examples/apim/137-api_management_notification_recipient_email/configuration.tfvars)
includes the resource group and APIM. Set a real recipient before deployment.
After parent-managed examples initialization:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_notification_recipient_email -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/137-api_management_notification_recipient_email/configuration.tfvars -no-color
```

Contracts mock AzureRM/CAF and plan only, asserting local/cross-zone IDs,
recipient/type passthrough, explicit ID precedence and supported timeout
defaults/overrides. They do not prove notification delivery.
Use an approved subscription; plan/review/apply this single scenario, inspect
APIM notification recipients and destroy with the same file when finished.
Root/CI integration belongs to the parent task.
