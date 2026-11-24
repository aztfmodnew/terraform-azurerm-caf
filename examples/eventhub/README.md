# Azure Event Hub

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

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmod/terraform-azurerm-caf/tree/main/examples/eventhub).

## Focused scenarios

- `100-simple-eventhub-namespace` creates a namespace.
- `102-namespace-and-evh-with-auth-rules` demonstrates legacy SAS compatibility.
- `103-eventhub-consumer-groups` creates consumer groups.
- `104-namespace-and-evh-with-storage` creates capture destinations.
- `105-ai-gateway-eventhub` demonstrates TLS 1.2, disabled local/public access,
  managed identities, keyless namespace RBAC, hubs, and a consumer group.

Focused contracts live under `examples/tests/unit/event_hubs/` and can be run
with an explicit test directory, for example:

```shell
terraform -chdir=examples test -test-directory=tests/unit/event_hubs/namespaces -no-color
terraform -chdir=examples test -test-directory=tests/unit/event_hubs/hubs -no-color
terraform -chdir=examples test -test-directory=tests/unit/event_hubs/namespaces/auth_rules -no-color
```

The contracts are plan-only checks. They do not verify Azure service-side
behavior or RBAC propagation.
