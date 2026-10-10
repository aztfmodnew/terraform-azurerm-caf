# Managed database ARM deployment

The module retains its inline database and retention template, parameter
defaults, resource names, deployment address and destroy provisioner.
AzAPI object outputs are accessed directly for the database ID and destroy
command; they must not be decoded as JSON strings.

Existing CamelCase settings remain supported. Additional database options are
`autoCompleteRestore`, `catalogCollation`, cross-subscription ID properties,
`isLedgerOn`, `lastBackupName`, `recoverableDatabaseId`,
`restorableDroppedDatabaseId`, `storageContainerIdentity`,
`storageContainerSasToken` and `storageContainerUri`.

Optional `deployment` settings include `location`, `identity`, `external_inputs`,
`external_input_definitions`, `extension_configs`, `validation_level`,
`debug_setting_detail_level`, `expression_evaluation_scope` and
`on_error_deployment = { type, deployment_name }`.
CRUD `settings.timeouts` controls the deployment.
Remote template and parameter links are not exposed: this module manages a
database using its own inline template, not an arbitrary ARM deployment.

Use the [shared test guide](../../../examples/tests/README.md) with an existing
managed-database example's complete configuration. Keep mock tests plan-only:
the existing destroy provisioner invokes Azure CLI. Mock planning does not
verify deployment execution, restore semantics or that destroy command.
