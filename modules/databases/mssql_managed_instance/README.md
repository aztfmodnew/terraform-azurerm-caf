# Managed instance password and lookup

Generated-password storage and managed-instance lookup behavior remain supported.
`administrator_password_secret` accepts `tags`, `content_type`, `enabled`,
`expiration_date`, `not_before_date` (Unix timestamps) and CRUD `timeouts`.
`managed_instance_lookup_timeouts.read` controls the AzAPI data lookup.
These settings do not change the AzureRM managed-instance resource interface.

Initialize examples, then run from the repository root:

```shell
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=mssql_mi/200-mi/configuration.tfvars \
  -var-file=mssql_mi/200-mi/nsg.tfvars
```

Mock plans do not verify secret access or managed-instance provisioning.
See the [test guide](../../../examples/tests/README.md).
