# Simple service tag

Creates a resource group, Developer APIM service and service-level tag using
local CAF key references. No remote state, literal ARM IDs or pre-existing
APIM resources are required. Use the generated name output, not display_name,
for separately managed API/product associations.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/148-api_management_tag/configuration.tfvars
```

Review before applying with the same file. Verify tag name and display label
in APIM. Remove downstream associations before cleanup, then review and execute
`destroy` with the same file. The managed APIM service and resource group are
deleted as well. Developer APIM incurs charges while deployed.

See the [module's plan-only mock contract](../../../modules/apim/api_management_tag/README.md).
Mocks check naming/reference behavior, not service-side uniqueness or existence.
