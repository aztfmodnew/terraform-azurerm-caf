# Databricks Workspace

This CAF module manages an Azure Databricks workspace, its diagnostics and private endpoints, and the optional root DBFS customer-managed key resource. The workspace and DBFS key settings are aligned with the AzureRM 5.9.0 resource schemas.

## Configuration coverage

The `settings` input supports the AzureRM workspace arguments, both provider nested blocks (`custom_parameters` and `enhanced_security_compliance`), provider timeouts, and the optional `azurerm_databricks_workspace_root_dbfs_customer_managed_key` resource. Provider schema details and valid values are described in `variables.tf`.

Key Vault keys and Databricks Access Connectors can be referenced with `{ key = "...", lz_key = "..." }`; the root aggregator passes the corresponding combined objects. Existing direct IDs and the legacy top-level `machine_learning` key reference remain supported. The module keeps its prior `no_public_ip = false` and workspace delete-timeout `60m` defaults to avoid changing existing deployments.

When configuring root DBFS CMK, set `customer_managed_key_enabled = true`, provide a direct Key Vault key ID or a `key_vault_key` CAF reference, and grant the workspace storage identity the required Key Vault permissions. Terraform mock tests do not verify Azure permissions or service-side acceptance.

## Examples and validation

The examples are independent configurations; run each separately with the existing shared mock runner:

```bash
terraform -chdir=examples test -test-directory=./tests/mock -var-file=./databricks/100-standard-databricks-no-vnet/configuration.tfvars -verbose
terraform -chdir=examples test -test-directory=./tests/mock -var-file=./databricks/101-standard-databricks-vnet/configuration.tfvars -verbose
terraform -chdir=examples test -test-directory=./tests/mock -var-file=./databricks/102-premium-databricks-vnet-private-endpoint/configuration.tfvars -verbose
terraform -chdir=examples test -test-directory=./tests/mock -var-file=./databricks/102-premium-aml/configuration.tfvars -verbose
```

The focused plan-only contract checks dependency resolution, provider argument wiring, outputs, and legacy AML references. It is opt-in and does not change the shared mock runner or CI pipeline:

```bash
terraform -chdir=examples init -backend=false -input=false -test-directory=tests/unit/analytics/databricks_workspace
terraform -chdir=examples test -test-directory=tests/unit/analytics/databricks_workspace -no-color
```
