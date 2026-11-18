# Simple product tag association

Creates a resource group, Developer APIM service, product, service tag and
product/tag association using local CAF keys. No remote state, literal ARM IDs
or pre-existing APIM resources are required. The association resolves the
managed tag's generated name and the product's short product_id.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/145-api_management_product_tag/configuration.tfvars
```

Review and apply with the same file only when approved. Verify the tag appears
on the product. For cleanup, review and execute `destroy` with the same file;
it deletes the managed tag, product, APIM service and resource group too.
Developer APIM incurs charges while deployed.

The [module's plan-only mock contract](../../../modules/apim/api_management_product_tag/README.md)
checks short identifiers and references, not Azure tag existence.
