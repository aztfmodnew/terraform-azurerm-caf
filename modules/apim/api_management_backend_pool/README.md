# APIM backend pool

Creates a `Microsoft.ApiManagement/service/backends` resource with `type = "Pool"` through AzAPI 2.13.0. AzureRM 5.14.0 lacks a pool argument and requires `protocol` plus `url`, so it cannot represent this ARM resource shape.

Members resolve by:

1. direct child backend `id`;
2. CAF key and `source` (`ai_backends` or `backends`, with landing-zone selection);
3. child backend `name` within the selected APIM service.

Each member must select exactly one of `id`, `key`, or `name` and supports ARM `weight` and `priority` values from 0 through 100. Stable `2024-05-01` supplies the basic pool. Preview `2024-10-01-preview` adds cookie session affinity and pool failure responses; `2025-09-01-preview` additionally supports preview carbon fields. A pool accepts at most 30 members.

Outputs are normalized as `id`, CAF `name`, `service_ids`, and ARM `properties`. Optional resource/action timeouts and backend reconnect action inputs are exposed.

## Contract validation

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_backend_pool
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_backend_pool -no-color
```

The contract suite uses mocked providers, so it does not contact Azure or perform provider-side schema validation. It verifies the generated ARM body and behavioral assertions for direct and remote references, negative references, boundary weights, priorities, preview-only session affinity, failure response, naming, and operation inputs. The ARM contract is documented in `SCHEMA.md` and must also be exercised by a real plan when upgrading the supported API version.
