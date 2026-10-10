# Azure Synapse Analytics

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

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmod/terraform-azurerm-caf/tree/main/examples/synapse_analytics).

## Workspace configuration coverage

The workspace module supports the optional AzureRM Synapse workspace
configuration, including Entra-only authentication, a compute subnet, managed
identity, customer-managed keys, Git integration, tenant linking, public
network access, Purview, and workspace timeouts. Existing SQL pools, Spark
pools, private endpoints, generated Key Vault secrets, and both firewall-rule
interfaces remain supported. The legacy single `workspace_firewall` setting is
preserved for compatibility.

The deployment examples are independent configurations. Run their existing
shared mock plans separately:

```bash
terraform -chdir=examples test -test-directory=./tests/mock \
  -var-file=./synapse_analytics/100-synapse/configuration.tfvars -no-color

terraform -chdir=examples test -test-directory=./tests/mock \
  -var-file=./synapse_analytics/101-synapse-sparkpool/configuration.tfvars -no-color
```

The focused, plan-only contract checks provider option wiring, local and remote
managed identity resolution, generated secret tags, Git integration, both
firewall interfaces, and the AAD administrator. It does not validate Azure-side
acceptance, deployment behavior, password rotation, or idempotency. It is an
opt-in local suite and does not change CI selection:

```bash
terraform -chdir=examples init -backend=false -input=false \
  -test-directory=tests/unit/analytics/synapse
terraform -chdir=examples test \
  -test-directory=tests/unit/analytics/synapse -no-color
```
