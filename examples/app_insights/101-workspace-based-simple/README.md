# Application Insights and Log Analytics compatibility

This example covers omitted Application Insights flags, legacy disabled flags
and explicit current-name precedence. Omitted and null legacy flags retain the
provider defaults rather than being negated.

For Application Insights, use `daily_data_cap_notifications_enabled` and
`ip_masking_enabled`. The legacy `daily_data_cap_notifications_disabled` and
`disable_ip_masking` inputs remain supported and are inverted when supplied.
Current names take precedence.

For Log Analytics, use `internet_ingestion_access_type` and
`internet_query_access_type`. Legacy `internet_ingestion_enabled` and
`internet_query_enabled` booleans map to `Enabled` or `Disabled`. Explicit
access-type inputs take precedence. The legacy workspace in this example
disables public ingestion and queries; it is not intended for telemetry use.

Mock validation from the repository root:

```bash
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=./app_insights/101-workspace-based-simple/configuration.tfvars
```

Validated against the AzureRM 5.8 schemas for
[Application Insights](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/application_insights)
and [Log Analytics](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/log_analytics_workspace).
