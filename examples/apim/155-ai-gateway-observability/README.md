# AI Gateway Log Analytics and APIM observability

This integrated example combines:

- a Developer-tier API Management service and API;
- an identity-authenticated Event Hub logger for APIM service and API diagnostics;
- an Azure Monitor diagnostic setting that sends APIM platform logs and metrics
  to a PerGB2018 Log Analytics workspace; and
- the minimum RBAC required for the user-assigned identity to send Event Hub data.

The APIM logger's `azuremonitor` diagnostics and the service's Azure Monitor
diagnostic setting are intentionally separate telemetry paths and do not create
duplicate resource ownership.

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
