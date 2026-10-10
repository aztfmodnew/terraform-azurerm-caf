# Standard availability tests

The AzAPI web test sends both top-level `kind` and `properties.Kind`.
Optional settings include `ignore_http_status_code`, `configuration.web_test`
and CRUD `timeouts`. Existing defaults and raw ARM `content_validation`
properties (`ContentMatch`, `IgnoreCase`, `PassIfTextFound`) remain supported.
Unset optional request and validation fields are omitted.

Required settings are `request_url` and `geo_locations`. Headers are ARM
`key`/`value` entries and `request_body` is base64 encoded. Frequency accepts
300, 600 or 900 seconds. Certificate lifetime checking requires enabled SSL
checking and a positive number of days. Existing defaults remain unchanged,
including `parse_dependent_requests = false`.

The root uses `webapp.azurerm_application_insights_standard_web_test`; the
examples wrapper exposes `azurerm_application_insights_standard_web_test`.
The Application Insights link is carried by the `hidden-link` tag.
Sources: [ARM contract](https://learn.microsoft.com/azure/templates/microsoft.insights/2022-06-15/webtests)
and [AzAPI 2.13.0](https://registry.terraform.io/providers/Azure/azapi/2.13.0/docs/resources/resource).

Focused, plan-only contracts assert body configuration, defaults, linking and
timeouts, plus invalid frequency and SSL combinations:

```shell
terraform -chdir=examples init -backend=false -input=false -test-directory=tests/unit/app_insights/standard_web_test
terraform -chdir=examples test -test-directory=tests/unit/app_insights/standard_web_test -no-color
```

From the repository root, test the existing example with the shared runner:

```shell
terraform -chdir=examples test -test-directory=tests/mock -var-file=app_insights/103-web-test/configuration.tfvars
```

Initialize examples first. This checks mock plan generation, not execution of
the availability test in Azure. See the [test guide](../../../examples/tests/README.md).
