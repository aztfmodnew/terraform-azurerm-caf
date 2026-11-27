# Cognitive Account Project

Creates an `azurerm_cognitive_account_project` under an Azure AI Services
(`AIServices`) account.

The parent account must enable `project_management_enabled`, define a custom
subdomain, and have a managed identity. Project identity defaults to
`SystemAssigned`; local, remote, and direct user-assigned identity IDs are
supported for user-assigned identity types.

## Inputs

| Name | Required | Description |
| --- | --- | --- |
| `global_settings` | yes | CAF regions, tags, and naming context |
| `client_config` | yes | Landing-zone identity |
| `settings` | yes | Project name, location, identity, description, display name, tags, and timeouts |
| `cognitive_account_id` | yes | Parent AIServices account resource ID |
| `remote_objects` | no | Managed identity references |
| `base_tags` | no | Inherit global tags |

## Outputs

Exports `id`, `name`, `default`, `endpoints`, `principal_id`, `tenant_id`, and
`rbac_id`. `default` and `endpoints` are computed by Azure; identity outputs
forward the project's computed managed-identity principal and tenant IDs, with
`rbac_id` exposing the principal ID for CAF role mappings.

Optional `settings.timeouts` accepts `create`, `read`, `update`, and `delete`
operation durations.
