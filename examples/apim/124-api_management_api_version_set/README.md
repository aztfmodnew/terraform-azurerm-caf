# Simple API version set

Creates a resource group, Developer APIM service and segment-based version set
using local CAF key references. No remote state, hardcoded ARM IDs or existing
APIM resources are needed. The generated version-set ARM ID can be used by
separately configured APIs.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/124-api_management_api_version_set/configuration.tfvars
```

Review before applying with the same file. Verify the versioning scheme and
display name in APIM. Remove dependent API references before cleanup, then
review and execute `destroy` with the same variable file. Cleanup also removes
the managed APIM service and resource group. Developer APIM incurs charges.

The [module's plan-only mock contract](../../../modules/apim/api_management_api_version_set/README.md)
covers Segment/Header/Query settings, not live API version routing.
