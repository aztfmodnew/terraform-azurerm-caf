# Fabric Capacity module

This module manages an Azure Fabric Capacity using the CAF naming and resource
group conventions. The underlying AzureRM resource supports `sku`,
`administration_members`, `tags`, and create, read, update, and delete
timeouts. The supported SKU names are `F2`, `F4`, `F8`, `F16`, `F32`, `F64`,
`F128`, `F256`, `F512`, `F1024`, and `F2048`; the tier is `Fabric`.

`administration_members` accepts Entra user UPNs and service-principal object
IDs. The module applies `Fabric` when `sku.tier` is omitted and validates the
provider-supported SKU names and tier. Fabric Capacity does not currently
support the diagnostics or private endpoint integrations in this repository.

## Examples and tests

- Shared example: `examples/fabric_capacity/100-basic-fabric-capacity/configuration.tfvars`
- Shared plan-only mock:

  ```bash
  terraform -chdir=examples init -backend=false -input=false
  terraform -chdir=examples test \
    -test-directory=./tests/mock \
    -var-file=./fabric_capacity/100-basic-fabric-capacity/configuration.tfvars \
    -no-color
  ```

- Opt-in module contract:

  ```bash
  terraform -chdir=examples init -backend=false -input=false \
    -test-directory=tests/unit/analytics/fabric_capacity
  terraform -chdir=examples test \
    -test-directory=./tests/unit/analytics/fabric_capacity \
    -no-color
  ```

The contract checks the complete provider configuration surface, the default
SKU tier, returned values, and rejection of unsupported SKU names and tiers.
Plan-only tests do not verify that the specified Entra identities exist or
that Azure accepts the deployment.
