# Validated provider and ARM contract

The repository lock selects `azure/azapi` 2.13.0 and `hashicorp/azurerm` 5.14.0.

## AzureRM 5.14.0 gap

`azurerm_api_management_backend` only represents a `Single` backend. It requires `protocol` and `url`, targets APIM API `2024-05-01`, and exposes no ARM `type`, `pool.services`, `pool.sessionAffinity`, or pool `failureResponse` fields. It therefore cannot manage a backend pool.

## AzAPI 2.13.0 ARM contract

The provider accepts `Microsoft.ApiManagement/service/backends` stable `2024-05-01` and preview versions through `2025-09-01-preview`.

| API version | Pool contract |
| --- | --- |
| `2024-05-01` | `type = "Pool"` and `pool.services[{ id, weight, priority }]` |
| `2024-10-01-preview` | Adds `pool.sessionAffinity.sessionId` and `pool.failureResponse.statusCode` |
| `2025-03-01-preview`, `2025-09-01-preview` | Adds carbon-aware fields including member `preferredCarbonEmission` |

Member IDs are service child IDs:

```text
/subscriptions/<subscription>/resourceGroups/<group>/providers/Microsoft.ApiManagement/service/<service>/backends/<backend>
```

The ARM backend contract does not contain a managed-identity credential field. Authentication is represented by the APIM `authentication-managed-identity` policy, as implemented by the AI backend module's `authentication_policy` output.

Authoritative references used for validation:

- Azure/terraform-provider-azapi v2.13.0 resource schema:
  `https://github.com/Azure/terraform-provider-azapi/blob/v2.13.0/docs/resources/Microsoft.ApiManagement_service_backends.md`
- Azure REST API specification:
  `https://github.com/Azure/azure-rest-api-specs/tree/main/specification/apimanagement/resource-manager/Microsoft.ApiManagement/ApiManagement`
- APIM backend and policy documentation:
  `https://learn.microsoft.com/azure/api-management/backends`
  and `https://learn.microsoft.com/azure/api-management/authentication-managed-identity-policy`

Mock contracts verify Terraform's generated resource bodies and module behavior without contacting Azure. Real provider planning remains required for API-version schema verification during upgrades.
