# Azure Monitor Private Link Scope

Creates an Azure Monitor Private Link Scope (AMPLS), links Log Analytics workspaces
or Application Insights components, and creates the scope's `azuremonitor`
private endpoint integration.

## Features

- All AzureRM 5.14 AMPLS access-mode, tag, and timeout settings.
- Log Analytics, Application Insights, or direct linked-resource IDs.
- Scoped-service create, read, and delete timeouts.
- CAF naming for the scope and every scoped service.
- Private endpoints with `azuremonitor` as the default subresource.
- Private DNS zone-group references and inherited tags.

AMPLS does not expose Azure diagnostic settings, so no diagnostics integration
is included.

## Inputs

| Name | Description |
| --- | --- |
| `global_settings` | CAF naming, region, and tag settings. |
| `client_config` | Current landing-zone identity. |
| `settings.name` | AMPLS logical name. |
| `settings.resource_group` / `resource_group_name` | Resource group reference or direct name. |
| `settings.ingestion_access_mode` | `Open` (default) or `PrivateOnly`. |
| `settings.query_access_mode` | `Open` (default) or `PrivateOnly`. |
| `settings.scoped_services` | Map of scoped services using `linked_resource_id`, `log_analytics`, or `application_insights`. |
| `settings.private_endpoints` | Private endpoint configurations. AMPLS uses the `azuremonitor` subresource by default. |
| `settings.timeouts` | Scope create/read/update/delete timeouts. |
| `remote_objects` | Combined resource groups, monitoring resources, networks, and private DNS zones. |
| `base_tags` | Enables inherited global and resource-group tags. |

Each scoped service supports its own `timeouts` object with `create`, `read`, and
`delete` values.

## Outputs

The module exports `id`, `name`, `resource_group_name`, access modes,
`scoped_services`, and `private_endpoints`.

## Contract test

```shell
terraform -chdir=examples init -backend=false \
  -test-directory=tests/unit/monitoring/private_link_scope
terraform -chdir=examples test \
  -test-directory=tests/unit/monitoring/private_link_scope -no-color
```

See `examples/monitoring/105-private-monitoring` for an integrated VNet, five-zone
Azure Monitor DNS, Log Analytics, Application Insights, AMPLS, scoped-service,
and private-endpoint example.
