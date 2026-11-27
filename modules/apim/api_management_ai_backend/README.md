# APIM AI backend

Creates a `Microsoft.ApiManagement/service/backends` single backend with AzAPI 2.13.0. AzureRM 5.14.0's `azurerm_api_management_backend` requires a URL and has no pool `type`; the AzAPI resource is required for the AI routing contract and backend pools.

## Endpoint sources

Exactly one endpoint source should be selected:

- direct `endpoint` or `url` (must use HTTPS);
- `ai_services` or `cognitive_services_account`;
- `cognitive_deployment` or `cognitive_account_deployment`;
- `cognitive_account_project`, using `endpoint_key` or its first endpoint.

The input rejects configurations with multiple endpoint sources. AI references accept either an explicit HTTPS `endpoint` or a CAF `key` plus optional `lz_key`; direct AI/Cognitive ARM IDs are intentionally not accepted because an ARM ID alone does not reliably provide the backend's data-plane endpoint. Parent APIM references continue to support `id`, direct `name`, or CAF key. A referenced deployment may use its resolved ARM ID to derive an Azure OpenAI account host when its output has no explicit endpoint.

## Managed identity

The ARM backend schema contains no identity property. Managed identity is applied through APIM policy with the exported `authentication_policy` fragment. Omitting `managed_identity.client_id` emits the system-assigned identity form. Supplying a direct client ID or a managed-identity CAF key emits the user-assigned form.

The module defaults to managed identity and intentionally provides no API-key credential input. Use the existing named-value module with `value_from_key_vault` for unrelated secure policy values.

## Inputs

See `variables.tf`. Supported API versions are stable `2024-05-01` and the provider-supported preview contracts through `2025-09-01-preview`. Resource and reconnect-action timeouts are independently configurable.

## Outputs

`id`, `name`, `url`, `endpoint`, identity metadata, `authentication_policy`, and normalized ARM `properties`.

## Contract validation

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_ai_backend
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_ai_backend -no-color
```

The suite covers direct HTTPS onboarding, managed-identity reference normalization, all supported AI endpoint reference families, mutually exclusive endpoint sources, policy composition, resource actions, timeouts, CAF naming, and HTTPS rejection. It uses mocked providers and does not contact Azure.
