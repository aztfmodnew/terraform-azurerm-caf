# Application Insights

This module retains its legacy individual inputs for naming, telemetry limits,
retention, sampling, workspace, tags and diagnostics. Additional provider options
are supplied through `settings`:

| Setting | Default when omitted |
| --- | --- |
| `local_authentication_enabled` | `true` |
| `internet_ingestion_enabled` | `true` |
| `internet_query_enabled` | `true` |
| `force_customer_storage_for_profiler` | `false` |
| `timeouts.create` | `60m` |
| `timeouts.read` | `5m` |
| `timeouts.update` | `30m` |
| `timeouts.delete` | `30m` |

The root accepts these options in each `webapp.azurerm_application_insights`
entry; the examples wrapper exposes `azurerm_application_insights` directly.
`workspace_id` takes precedence over the existing local/remote
`log_analytics_workspace` key reference and diagnostic destination reference.
The enabled notification and IP-masking inputs retain precedence over their
legacy disabled aliases.

Public access settings must match the workload's connectivity. Disabling local
authentication requires Microsoft Entra-authenticated telemetry clients.
Private connectivity is provided through Azure Monitor Private Link Scope,
not a private endpoint attached directly to the component.

References:
- [AzureRM Application Insights resource](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/application_insights)
- [Microsoft Entra authentication](https://learn.microsoft.com/azure/azure-monitor/app/azure-ad-authentication)
- [Azure Monitor Private Link](https://learn.microsoft.com/azure/azure-monitor/fundamentals/private-link-security)

## Local verification

From the repository root:

```shell
terraform -chdir=examples init -backend=false -input=false -test-directory=tests/unit/app_insights
terraform -chdir=examples test -test-directory=tests/unit/app_insights -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=app_insights/100-all-attributes/configuration.tfvars -no-color
```

The opt-in contracts assert access/profiler configuration, all timeout operations,
provider defaults, legacy alias precedence and direct workspace-ID root resolution.
Existing examples cover standalone
and workspace-based components. Mock plans do not verify service acceptance,
telemetry delivery, authentication or lifecycle behavior in Azure.
