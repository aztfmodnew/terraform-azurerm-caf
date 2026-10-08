# Container Registry with geo-replication

This Premium registry example includes a West Europe replica to exercise the
AzureRM 5.8 required `global_endpoint_routing_enabled` field. CAF supplies
`false` when the setting is omitted. Set it explicitly to `true` when the
replica should participate in global login-server routing.

The field is independent of data replication: disabling routing does not remove
the replica. The example does not push or pull container images.

Mock validation from the repository root:

```bash
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=./compute/container_registry/100-simple-acr/configuration.tfvars
```

Validated against the [AzureRM 5.8 registry schema](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/container_registry).
