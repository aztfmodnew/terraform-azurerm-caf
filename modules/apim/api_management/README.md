# API Management

Deploys an Azure API Management service with CAF naming, identities, networking,
hostnames, protocols, security, and optional Azure Monitor diagnostic settings.

Set `diagnostic_profiles` inside `settings`; the root API Management aggregator
passes the shared diagnostics object to `azurerm_monitor_diagnostic_setting`
for Log Analytics, Event Hub, Storage, or a supported partner solution.

APIM logger destinations and AzAPI upserts are not owned by this
module. Application Insights and Event Hub logger integration is configured by
the `api_management_logger` module; service and per-API telemetry is configured
by the corresponding APIM diagnostic modules.

See `examples/apim/155-ai-gateway-observability` for the integrated Log
Analytics, Event Hub logger, and APIM diagnostics pattern.

Focused contract:

```bash
terraform -chdir=examples test \
  -test-directory=tests/unit/apim/api_management \
  -no-color
```

The standard APIM diagnostic destination contract is:

```bash
terraform -chdir=examples test \
  -test-directory=tests/unit/apim/api_management_diagnostics \
  -no-color
```
