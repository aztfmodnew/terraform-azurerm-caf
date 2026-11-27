# API Management

Deploys an Azure API Management service with CAF naming, identities, networking,
hostnames, protocols, security, and optional Azure Monitor diagnostic settings.

The service supports optional inbound private endpoints through the standard
AzureRM `azurerm_private_endpoint` resource. Private endpoints always target
the APIM `Gateway` subresource and can resolve subnet and
`privatelink.azure-api.net` DNS zone references from CAF combined objects or
consume direct ARM IDs. Private connectivity is separate from APIM VNet
injection; existing `virtual_network_type`, `virtual_network_configuration`,
and public-access controls remain unchanged.

AzureRM 5.14 does not define an
`azurerm_api_management_private_endpoint` resource. Do not replace the
standard private endpoint with AzAPI. Microsoft supports inbound Private Link
for Developer, Basic, Standard, Standard v2, Premium, and Premium v2, with only
the `Gateway` subresource and `privatelink.azure-api.net` as the recommended
private DNS zone. Consumption is not supported.

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
