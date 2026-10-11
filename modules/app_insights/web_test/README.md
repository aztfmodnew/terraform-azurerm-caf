# Legacy availability tests

Existing classic web-test configurations and resource addresses remain supported.
URL ping tests are deprecated by Microsoft; new availability monitoring should
use the [standard-test module](../standard_web_test/README.md). This legacy
module is intentionally not extended.

Migration is an explicit lifecycle and cost decision, not a provider-resource
rename. Create and validate a standard test, migrate alerts separately, and
remove the old test only after an approved cutover. Existing
`app_insights/103-web-test` remains a compatibility example.
See [Microsoft availability monitoring and migration](https://learn.microsoft.com/azure/azure-monitor/app/availability).
