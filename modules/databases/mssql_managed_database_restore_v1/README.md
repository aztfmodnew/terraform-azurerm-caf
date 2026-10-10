# Managed database restore

The existing snake_case `properties` contract supports
`cross_subscription_source_database_id`,
`cross_subscription_restorable_dropped_database_id`,
`cross_subscription_target_managed_instance_id`, `is_ledger_on` and
`storage_container_identity`. Existing restore modes and source IDs remain
supported. Supply the required `short_term_retention_days`.

Timeouts are configurable through `settings.timeouts`,
`short_term_retention_timeouts` and `long_term_retention_policy.timeouts`.
`long_term_retention_policy.backup_storage_access_tier` is optional.

Use the existing restore example and its landing-zone dependencies with the
[shared test guide](../../../examples/tests/README.md). Mock planning does not
verify source-backup availability or cross-subscription restore permissions.
