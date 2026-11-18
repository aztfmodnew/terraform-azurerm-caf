# Simple external Redis cache registration

Creates a resource group, Developer APIM service, Standard Redis 6 cache and
APIM cache registration using local CAF keys. The module resolves the real
primary connection string from the managed Redis output. No remote state,
hardcoded ARM IDs, endpoints or credentials are required. Terraform state
contains the generated connection string and must be protected.
TLS is enabled and the non-TLS Redis port is disabled.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/146-api_management_redis_cache/configuration.tfvars
```

After reviewing the plan and estimated charges, apply with the same inputs.
Verify registration and separately test cache policies against Redis. To clean
up, review and execute `destroy` with the same inputs; this deletes Redis,
APIM and the resource group too. Remove dependent policies before cleanup.

See the [module plan-only mock contract](../../../modules/apim/api_management_redis_cache/README.md).
Mocks do not connect to Redis or prove live authentication/network access.
