# Azure AI Services

This module is part of Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate this directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.26.1"

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

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/master/examples/ai_services).

## AzureRM 5 migration

The module now manages AI Services as `azurerm_cognitive_account` with `kind = "AIServices"`. Its `project_management_enabled` setting defaults to `true` to preserve the previous `azurerm_ai_services` behavior.

AzureRM 5.8 requires a managed identity when project management is enabled.
If `identity` is omitted, CAF supplies `SystemAssigned` for that mode so the
existing minimal example remains valid. Explicit identity settings are preserved;
when project management is disabled, no default identity is added.

The `moved` block in `examples/ai_services.tf` only moves the module beneath the examples wrapper; it does not migrate the managed resource from `azurerm_ai_services` to `azurerm_cognitive_account`. The AzureRM migration documentation describes the replacement resource and attribute changes but does not provide a cross-resource-type state move. For an existing deployment, back up the state, inspect the actual address with `terraform state list`, then remove the old resource address from state and import the existing Azure account at the new resource address before planning. Use the same Azure resource ID; do not apply a plan that proposes both destroying and recreating the account.

## Private connectivity and RBAC

The module accepts `private_endpoints` alongside the existing `network_acls`
configuration; private endpoints do not replace IP or virtual-network rules.
Subnet references support both direct `subnet_id` values and CAF `vnet_key` /
`subnet_key` references. The default private-link subresource is `account`.

AI Services can participate in any of the three standard private DNS zones:

- `privatelink.cognitiveservices.azure.com`
- `privatelink.openai.azure.com`
- `privatelink.services.ai.azure.com`

See `101-private-endpoint-rbac` for an account, all three DNS zone groups, and
`Cognitive Services OpenAI User` role assignments to APIM, managed-identity, and
direct principal references.

Focused contract test:

```shell
terraform -chdir=examples test \
  -test-directory=./tests/unit/cognitive_services/ai_services \
  -no-color
```

Shared example mock:

```shell
terraform -chdir=examples test \
  -test-directory=./tests/mock \
  -var-file=./ai_services/101-private-endpoint-rbac/configuration.tfvars \
  -no-color
```
