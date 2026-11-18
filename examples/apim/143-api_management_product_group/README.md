# Simple product group association

Creates a resource group, Developer APIM service, custom group, product and
product/group association using local CAF key references. The product uses
its short product_id. No remote state, literal ARM IDs or pre-existing APIM
resources are required, and no association is managed twice.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/143-api_management_product_group/configuration.tfvars
```

Review before applying with the same file. Verify the group is linked to the
product and separately check intended developer access. For cleanup, review
and execute `destroy` with the same file. The managed group, product, APIM
service and resource group are deleted too. Developer APIM incurs charges.

See the [module mock contract](../../../modules/apim/api_management_product_group/README.md).
Plan-only mocks verify ID/name wiring, not live access control.
