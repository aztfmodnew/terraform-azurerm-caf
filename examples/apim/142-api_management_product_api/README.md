# Simple product API association

Creates a resource group, Developer APIM service, API, product and product/API
association with local CAF key references. The managed product exposes its
short product_id to the association. No remote state, literal ARM IDs or
pre-existing APIM resources are needed. Embedded association lists are not used.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/142-api_management_product_api/configuration.tfvars
```

Review before applying with the same file. Verify the API appears in the
product and test product subscription access separately. Clean up by reviewing
and executing `destroy` with the same file. This removes the managed API,
product, APIM service and resource group too. Developer APIM incurs charges.

See the [module's plan-only mock contract](../../../modules/apim/api_management_product_api/README.md).
Mock plans do not establish live product authorization.
