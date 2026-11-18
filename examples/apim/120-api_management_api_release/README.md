# Simple API release

Deploys a resource group, Developer APIM service, API revision 1 and its initial
release using local CAF key references. No pre-existing APIM resources, remote
state or literal ARM IDs are required. Five-character random naming suffixes
help avoid globally unique service-name collisions.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/120-api_management_api_release/configuration.tfvars
```

Review the plan, then use the same variable file with `apply` only when approved.
Verify the release and current API revision in APIM. Review and use `destroy`
with the same variable file to remove the complete example, including the APIM
service and resource group. Developer APIM incurs charges while deployed.

For safe offline validation, use the [module's plan-only contract](../../../modules/apim/api_management_api_release/README.md).
Mock plans do not publish revisions or verify Azure acceptance.
