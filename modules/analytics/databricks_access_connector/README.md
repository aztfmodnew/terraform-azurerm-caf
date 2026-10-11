# Databricks Access Connector module

The module manages an Azure Databricks access connector and supports system-assigned or user-assigned managed identities. User-assigned identities can be supplied directly or resolved from local and remote CAF managed identity keys. The `identity` output exposes the provider identity object, including computed principal and tenant IDs when available.

The connector name is taken from the module-level `name` variable (which the root supplies from the entry) and falls back to `settings.name`; one of them is required. Standalone callers that pass only `name` remain supported.

The resource supports configurable create, read, update, and delete timeouts. Provider defaults are 30 minutes for create, update, and delete, and 5 minutes for read.

## Examples and tests

- Shared example: `examples/databricks_access_connectors/100-databricks_access_connectors/configuration.tfvars`
- Shared plan-only mock:

  ```bash
  terraform -chdir=examples init -backend=false -input=false
  terraform -chdir=examples test \
    -test-directory=./tests/mock \
    -var-file=./databricks_access_connectors/100-databricks_access_connectors/configuration.tfvars \
    -no-color
  ```

- Opt-in module contract:

  ```bash
  terraform -chdir=examples init -backend=false -input=false \
    -test-directory=tests/unit/analytics/databricks_access_connector
  terraform -chdir=examples test \
    -test-directory=./tests/unit/analytics/databricks_access_connector \
    -no-color
  ```

The contract checks CAF identity-key resolution, identity output passthrough, optional identity omission, the legacy `name` variable versus `settings.name` fallback, and acceptance of the supported timeout settings. These plan-only tests do not verify that Azure accepts the configuration or executes operations within the configured timeouts.
