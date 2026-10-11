# Azure Machine Learning Workspaces

This module is part of Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate this directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.30.0"

  # Add object as described below
}
```

CAF Terraform module is iterative by default, you can instantiate as many objects as needed, using the following structure:

```hcl
resource_to_be_created = {
  object1 = {
    #configuration details as below
  }
  object2 = {
    #configuration details as below
  }
}
```

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmod/terraform-azurerm-caf/tree/main/examples/machine_learning).

## Workspace module coverage

The workspace module exposes the AzureRM 5.9 workspace arguments and nested
blocks, including identity, encryption, managed networking, feature store,
serverless compute, tags, and operation timeouts. `identity` defaults to
`SystemAssigned`; it also accepts direct identity IDs and local or remote CAF
managed-identity keys. The existing `compute_instances` child-module setting is
retained for compatibility; use the standalone
`machine_learning_compute_instance` module for new deployments.

Workspace managed-network outbound rules are configured under
`network_outbound_rules`, with keyed `fqdn`, `private_endpoint`, and
`service_tag` maps. Rule names default to their map keys. The private-endpoint
rule accepts a direct `service_resource_id`; private endpoint connectivity to
the workspace itself is configured separately under `private_endpoints` and
uses the `amlworkspace` subresource.

The workspace module integrates CAF diagnostic profiles through the shared
diagnostics module. Use the root `diagnostics_definition` and
`diagnostics_destinations` configuration with `diagnostic_profiles` on the
workspace. Resource log categories and metric availability are service
specific; consult the [Azure Machine Learning monitoring data
reference](https://learn.microsoft.com/en-us/azure/machine-learning/monitor-azure-machine-learning-reference?view=azureml-api-2).

## Compute instance module coverage

The standalone `machine_learning_compute_instance` module exposes the
AzureRM 5.9.0 compute-instance arguments, including user assignment, managed
identity references, SSH configuration, subnet and public-IP settings, local
authentication, tags, and the supported create/read/delete timeouts. Workspace
and subnet dependencies accept direct IDs or CAF key references. Existing
example inputs and the legacy workspace `compute_instances` setting remain
supported.

The opt-in contract at
`examples/tests/unit/analytics/machine_learning_compute_instance/contract.tftest.hcl`
asserts the exposed provider options, local and remote identity resolution,
default provider behavior, tags, and module outputs. The module also exposes
the schema-supported create/read/delete timeouts. Run the contract from the
repository root:

```sh
terraform -chdir=examples init -backend=false \
  -test-directory=tests/unit/analytics/machine_learning_compute_instance
terraform -chdir=examples test \
  -test-directory=tests/unit/analytics/machine_learning_compute_instance -no-color
```

The contract is plan-only and opt-in; it does not validate Azure-side
acceptance, network reachability, or authentication to the compute instance.
The schema reference used for this module is
[AzureRM 5.9.0](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/machine_learning_compute_instance).

## Examples and tests

- `100-aml` exercises the existing workspace and legacy compute-instance
  configuration.
- `101-aml-vnet` demonstrates private workspace access and both required
  workspace DNS zones. Its README documents the two-file order and mock-plan
  command.
- The opt-in module contract at
  `examples/tests/unit/analytics/machine_learning/contract.tftest.hcl`
  checks provider arguments, nested blocks, the three managed-network rule
  resources, identity resolution, diagnostics wiring, outputs, and defaults.

Run the contract from the repository root:

```sh
terraform -chdir=examples init -backend=false \
  -test-directory=tests/unit/analytics/machine_learning
terraform -chdir=examples test \
  -test-directory=tests/unit/analytics/machine_learning -no-color
```

These are plan-only Terraform checks. They do not verify Azure-side resource
acceptance, outbound connectivity, private endpoint approval, or DNS
resolution. The AzureRM schema reference used for the workspace is
[version 5.9.0](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/machine_learning_workspace).
