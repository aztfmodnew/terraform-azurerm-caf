# Simple group user membership

Creates a resource group, Developer APIM service, custom group, APIM user and
group membership with local CAF key references. The managed user's ARM ID is
normalized to its logical ID by the membership module. No remote state, literal
ARM IDs or pre-existing APIM resources are required. No Entra user is created.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/130-api_management_group_user/configuration.tfvars
```

Review before applying with the same file. Verify group membership in APIM.
For cleanup, review and execute `destroy` with the same file; it removes only
the complete managed example, including the user, group, APIM service and
resource group. Developer APIM incurs charges while deployed.

See the [plan-only mock contract](../../../modules/apim/api_management_group_user/README.md).
It checks ARM-to-logical user-ID/short group-name conversion, not live group permissions.
