# Advanced network security perimeter

This example creates a perimeter with two profiles, inbound/outbound rules,
storage, Key Vault, and SQL associations in Learning mode, and diagnostics.
Review observed traffic before changing association mode to Enforced.

The configuration is split across seven files. `configurationbase.tfvars`
defines global settings; `resource_groups.tfvars` defines resource groups.
Load all files together; individual files are not standalone examples.
The existing networking CI scenario discovers all `.tfvars` files in this directory.

From the repository root, run the mocked integration test:

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/mock
terraform -chdir=examples test \
  -test-directory=tests/mock \
  -var-file=networking/network_security_perimeter/300-nsp-advanced-deployment/configurationbase.tfvars \
  -var-file=networking/network_security_perimeter/300-nsp-advanced-deployment/resource_groups.tfvars \
  -var-file=networking/network_security_perimeter/300-nsp-advanced-deployment/storage_accounts.tfvars \
  -var-file=networking/network_security_perimeter/300-nsp-advanced-deployment/keyvaults.tfvars \
  -var-file=networking/network_security_perimeter/300-nsp-advanced-deployment/mssql_servers.tfvars \
  -var-file=networking/network_security_perimeter/300-nsp-advanced-deployment/diagnostics.tfvars \
  -var-file=networking/network_security_perimeter/300-nsp-advanced-deployment/network_security_perimeters.tfvars
```

For a real deployment, verify the target Azure subscription first, then use the
repository's `terraform_with_var_files` helper with
`--dir /networking/network_security_perimeter/300-nsp-advanced-deployment/`.
No real deployment is performed by the mock tests.
