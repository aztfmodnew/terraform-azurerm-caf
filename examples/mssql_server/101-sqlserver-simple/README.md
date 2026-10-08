# SQL Server and database auditing

This example creates one SQL Server, an S0 database, a Key Vault for the
generated administrator password and an LRS storage account for audit logs.
Server and database auditing are separate policies scoped to their respective
resources. Threat detection demonstrates legacy administrator-email flags.

The current `email_account_admins_enabled` setting takes precedence over legacy
`email_account_admins` and server `email_subscription_admins` settings. Server
security-alert settings are read from `security_alert_policy`, retaining the
older top-level fallbacks.

Database auditing now uses `azurerm_mssql_database_extended_auditing_policy`.
The previous root implementation referenced server and storage collections
using database keys, so it did not reliably manage a database policy. If an
existing state contains the old server-policy address, inspect the remote
resource before migrating: it is a server policy, not the database policy.
There is no automatic cross-resource-type `moved` block. Preserve/import the
server policy at its server address and import an existing database policy
at `azurerm_mssql_database_extended_auditing_policy.mssqldb["DATABASE_KEY"]`
before applying. Do not accept an unreviewed destroy plan for an existing
server auditing policy.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/mssql_server/101-sqlserver-simple/configuration.tfvars \
  -verbose
```
