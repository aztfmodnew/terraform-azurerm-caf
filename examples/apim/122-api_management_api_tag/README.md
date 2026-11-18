# Simple API tag association

Deploys a resource group, Developer APIM service, API, service tag and API/tag
association with local key references. No pre-existing resources, remote state
or literal ARM IDs are needed. The association resolves the managed tag's
generated resource name rather than its display label.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/122-api_management_api_tag/configuration.tfvars
```

Apply with the same file only after review. Verify the tag on the API in APIM.
To clean up, review and execute `destroy` with the same variable file; this
removes the complete example, including the API, tag, APIM service and resource
group. Developer APIM incurs charges until destroyed.

See the [plan-only mock contract](../../../modules/apim/api_management_api_tag/README.md).
Mocks check reference/name behavior, not tag existence in Azure.
