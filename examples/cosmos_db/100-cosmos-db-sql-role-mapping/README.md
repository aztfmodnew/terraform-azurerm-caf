# Cosmos DB SQL role mapping

This example uses managed identities and SQL role assignments with local
authentication disabled. Legacy `local_authentication_disabled = true` is
translated to the current `local_authentication_enabled = false` argument.
An explicitly supplied current argument takes precedence; a null legacy
argument retains the provider default.

Account primary-key outputs and the root account aggregate are sensitive.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/cosmos_db/100-cosmos-db-sql-role-mapping/configuration.tfvars \
  -verbose
```

Live testing requires Cosmos DB capacity in the chosen region. Select another
approved region if Azure rejects account creation due to regional capacity.
