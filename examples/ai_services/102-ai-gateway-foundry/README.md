# AI Gateway Foundry

Creates the lower Foundry platform layer for an AI gateway:

- an `AIServices` account with managed identity and diagnostic settings;
- a Foundry project linked by CAF account key;
- a GPT-4o deployment; and
- a user-assigned identity with a `Cognitive Services OpenAI User` assignment.

This example intentionally does not create API Management routes or policies,
Logic Apps, Cosmos DB, API Center resources, or application code.

## Validate

```shell
terraform -chdir=examples init
terraform -chdir=examples test \
  -test-directory=./tests/mock \
  -var-file=./ai_services/102-ai-gateway-foundry/configuration.tfvars \
  -no-color
```

Plan and apply only with approved Azure credentials. Destroy the example in
reverse dependency order after use.
