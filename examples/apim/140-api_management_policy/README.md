# Simple service-wide policy

Creates a resource group, Developer APIM service and singleton global policy
using local CAF keys. No remote state, hardcoded ARM IDs or existing APIM
resources are required. The managed parent does not embed another policy,
so policy ownership is not duplicated.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/140-api_management_policy/configuration.tfvars
```

Review the complete XML and its effect on every API before applying with the
same file. Verify the global policy and test representative API requests.
For cleanup, review `destroy` with the same file; removing the global policy
can affect live APIs. This example's cleanup also deletes its managed APIM
service and resource group. Developer APIM incurs charges while deployed.

See the [module's plan-only mock contract](../../../modules/apim/api_management_policy/README.md).
Mocks validate source selection and references, not policy execution.
