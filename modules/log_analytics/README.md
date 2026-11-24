# Log Analytics workspace

Deploys `azurerm_log_analytics_workspace` and optional
`azurerm_log_analytics_solution` resources with CAF naming and tagging.

## Workspace inputs

`log_analytics` supports the AzureRM 5.14 workspace arguments, including:

- `allow_resource_only_permissions`, `cmk_for_query_forced`,
  `data_collection_rule_id`, `immediate_data_purge_on_30_days_enabled`, and
  `local_authentication_enabled`;
- `internet_ingestion_access_type` and `internet_query_access_type`;
- `reservation_capacity_in_gb_per_day`, `sku`, `retention_in_days`, and
  `daily_quota_gb`;
- `identity.type` and optional `identity.identity_ids`;
- `timeouts.create`, `timeouts.read`, `timeouts.update`, and `timeouts.delete`.

Legacy `internet_ingestion_enabled`, `internet_query_enabled`, and the
misspelled `reservation_capcity_in_gb_per_day` inputs remain supported. Current
spellings take precedence.

`allow_resource_only_permissions` and `local_authentication_enabled` are
forwarded only when explicitly configured. When omitted, the AzureRM provider
and Azure service defaults remain authoritative.

`solutions_maps` is keyed by solution name. Each entry supports `publisher`,
`product`, `promotion_code`, `tags`, and the solution timeout fields.

## Outputs

The module exports the workspace `id`, `name`, `location`, `resource_group_name`,
`workspace_id`, managed-identity information, both shared keys (sensitive), and
the configured solution IDs.

## Tests

The focused AzureRM 5.14 contract is:

```bash
terraform -chdir=examples test \
  -test-directory=tests/unit/log_analytics \
  -no-color
```

Mock plans cover argument forwarding and legacy aliases; Azure permissions and
service-side identity behavior require a deployment.
