# AI Gateway Log Analytics, Application Insights and APIM observability

This integrated example combines:

- a Developer-tier API Management service and API;
- a workspace-based Application Insights resource linked to the example's
  Log Analytics workspace;
- an identity-authenticated Event Hub logger for APIM service diagnostics;
- an Application Insights logger for per-API diagnostics;
- an Azure Monitor diagnostic setting that sends APIM platform logs and metrics
  to a PerGB2018 Log Analytics workspace; and
- the minimum RBAC required for the user-assigned identity to send Event Hub data.

The service diagnostic keeps the Event Hub-backed `azuremonitor` identifier.
The API diagnostic uses the provider-valid `applicationinsights` identifier and
its matching Application Insights logger. AzureRM 5.14 internally defaults
`operation_name_format` for the API diagnostic resource, so `azuremonitor`
cannot be used for per-API diagnostics even when that attribute is omitted.
The service's Azure Monitor diagnostic setting remains a separate platform
telemetry path and does not create duplicate resource ownership.

This simple example uses public network connectivity for the Event Hub namespace.
Its namespace-level public access setting and network ruleset are both enabled so
the Developer-tier APIM service can send diagnostics without an Azure VNet path.

Production deployments that disable Event Hub public access require a complete
APIM VNet integration and Event Hub private endpoint, private DNS zone, and
DNS-link architecture. That private networking layer is intentionally outside
the scope of this numbered example.

Run the shared mock plan from the repository root:

```bash
terraform -chdir=examples test \
  -test-directory=./tests/mock \
  -var-file=./apim/155-ai-gateway-observability/configuration.tfvars \
  -no-color
```

This plan validates references and provider contracts only. Azure-side
permissions, category availability, and telemetry delivery require a deployment.
