# Kusto follower database

This example creates a leader cluster, its database and a follower cluster with
an attached database configuration. The leader exercises the existing
single-object `language_extensions` input with the R extension.

The module also accepts extension lists through `language_extensions` and the
current `language_extension` name. For attached databases,
`default_principal_modification_kind` takes precedence over the retained
`default_principal_modifications_kind` alias. The default is `None`.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/data_explorer/105-kusto_attached_database_configuration/configuration.tfvars \
  -verbose
```

Live deployment requires capacity for both Kusto clusters and support for the
selected language extension. The example does not execute database queries.

The leader uses two `Standard_E4d_v5` instances for the R sandbox; the smaller
`Dev(No SLA)_Standard_E2a_v4` SKU was rejected by Azure because it lacks the
required nested virtualization. The follower retains the development SKU.
