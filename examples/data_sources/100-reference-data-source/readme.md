This example demonstrates how to consume **existing resources** through `data_sources`.

You can either:
- create resources manually (portal/CLI/Terraform elsewhere) and reference them, or
- point to resources that already exist in the target subscription/tenant.

See `data_sources.tfvars` for reference patterns.

## Supported patterns

### 1) Explicit ID mode (legacy, backward compatible)
Use explicit `id` values in `data_sources.<type>.<key>`.

### 2) Name-based lookup mode (centralized)
For supported object types, provide lookup attributes and let `data_sources_lookup.tf`
resolve IDs centrally.

Validated object types in this example:
- `resource_groups` (by `name`)
- `subscriptions` (by `subscription_id`)
- `azuread_groups` (by `display_name`)
- `keyvaults` (by `name` + `resource_group_name`)
- `storage_accounts` (by `name` + `resource_group_name`)
- `recovery_vaults` (by `name` + `resource_group_name`)
- `vnets` and nested `subnets` (by `name` + `resource_group_name`)

## Important notes

- Keep keys stable: downstream resources reference keys like
	`existing_keyvault`, `existing_recovery_vault`, `vnet_existing`, etc.
- `resource_groups` and some data sources are resolved in the **current provider context**.
	Make sure `ARM_SUBSCRIPTION_ID` (or active Azure context) points to the correct subscription.