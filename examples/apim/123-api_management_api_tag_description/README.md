# Simple API tag description

Deploys a resource group, Developer APIM service, API, service tag, API/tag
association and its description. Local key references preserve the dependency
chain from the description to the API-level association (not the service tag).
No remote state, hardcoded ARM IDs or pre-existing APIM resources are needed.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/123-api_management_api_tag_description/configuration.tfvars
```

Review before applying with the same file. Verify the API tag's description and
documentation URL in APIM. Clean up with reviewed `destroy` using the same file;
this deletes the complete managed example, including the APIM service and
resource group. Developer APIM incurs charges while deployed.
Replace the illustrative documentation URL before deployment.

See the [module's plan-only mock contract](../../../modules/apim/api_management_api_tag_description/README.md);
it does not verify Azure tag ownership or the external site.
